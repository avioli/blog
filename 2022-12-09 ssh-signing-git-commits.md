# SSH signing git commits

I wanted to sign my commits for some time and tried it a year ago and it didn't really work.

... until 23rd of August 2022 when [GitHub announced that they will show verified flag for SSH signed commits](
https://github.blog/changelog/2022-08-23-ssh-commit-verification-now-supported/)

Today I re-tried - following a GitHub guide over several articles they have and have succeeded.

## The steps

TL;DR;

I started with their article about "[Signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)",
which led me to "[Telling Git about your SSH key](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key#telling-git-about-your-ssh-key)",
but then I had to follow the link at the top of the section to "[Generating a new SSH key and adding it to the ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)",
which led me to follow "[Adding a new SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)"
to add a new SSH signing key to my account. Finally I went back to the first
article where I created a temporary repository, where I signed a few commits and
confirmed the GitHub was showing the Verified flag.

Now the steps I took…


### 1. First thing was to create a new [Ed25519 signature](https://en.wikipedia.org/wiki/EdDSA#Ed25519):

```sh
ssh-keygen -t ed25519 -C "your_email@your_domain.com.au"
```

At the prompts that followed I picked the default file name and location since I
had no old Ed25519 key pairs, then put in a pass phrase I wanted, since I was
going to include it in my macOS keychain.

The `ssh-keygen` command has generated two new files: `~/.ssh/id_ed25519` and
`~/.ssh/id_ed25519.pub` - a private and public key pair.


### 2. Configuring SSH to load keys into the `ssh-agent` when communicating with GitHub

ASIDE: The `ssh-agent` manages your SSH keys and remembers your pass phrase.

Since the main purpose of signing my commits with an SSH key was to have a
verified flag on GitHub - I had to add a GitHub-related config to my SSH config
file at `~/.ssh/config`.

```
Host *.github.com
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
```

ASIDE: if you don't have the `~/.ssh/config` file - create it (I believe it
should have 0644 permissions, but I think the ssh agent ensures it
does automatically).

I use `UseKeychain yes`, because I'm going to store the password in my keychain.


### 3. Adding the SSH key to ssh-agent

Since I wanted to add my pass phrase to my macOS keychain I did:

```sh
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

ASIDE: If you get an error when you run `ssh-add` you'll have to start the
`ssh-agent`, which is trivially done via the command: `eval "$(ssh-agent -s)"`


### 4. Adding my public key to GitHub

Now I had to add the `.pub` file to my GitHub account:

```sh
pbcopy < ~/.ssh/id_ed25519.pub
```

ASIDE: `pbcopy` is a built-in macOS utility that simply copies the contents of
an input into the OS pasteboard (aka clipboard).

I opened `github.com` in a web browser and visited [my account's settings, where under SSH and GPG keys](https://github.com/settings/keys)
I've added the new public signing key with a descriptive name of my choosing.


### 5. Telling `git` about the SSH key

Finally I had to tell `git` to use the new key to sign my commits.

Apparently there is an important decision at this time - whether to sign all
your commits to all repositories OR just particular repository (or several).

I chose to go global, but if you do want to do it for a particular repo -
`cd` into it and use `--local` instead of my `--global` below.

```sh
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
```

Since I want to sign all my commits and didn't want to always type
`git commit -S ...` I added the oddly named config `commit.gpgSign`:

```sh
git config --global commit.gpgSign true
```


---

(this commit is my first signed one)

