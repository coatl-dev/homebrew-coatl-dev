# Contributing to Homebrew

First time contributing to Homebrew? Read our [Code of Conduct](https://github.com/coatl-dev/homebrew-coatl-dev/blob/HEAD/CODE_OF_CONDUCT.md).

Ensure your commits follow the [commit style guide](https://docs.brew.sh/Formula-Cookbook#commit).

Thanks for contributing!

## How To Contribute

:+1::tada: First off, thanks for taking the time to contribute! :tada::+1:

* [Getting Set Up To Contribute](#getting-set-up-to-contribute)
* [Adding a Formula](#adding-a-formula)
* [Updating a Formula](#updating-a-formula)

## Getting Set Up To Contribute

1. Fork the repository in GitHub with the **Fork** button
2. If you have not already done so, add your GitHub fork as a remote for your homebrew-coatl-dev Tap:

    ```sh
    github_user='<my-github-username>'
    cd "$(brew --repository)"/Library/Taps/coatl-dev/homebrew-coatl-dev
    git remote add "${github_user}" "https://github.com/${github_user}/homebrew-coatl-dev"
    ```

3. If you have already added your GitHub fork as a remote for your homebrew-cask Tap, ensure your fork is [up-to-date](https://help.github.com/articles/merging-an-upstream-repository-into-your-fork/)

Then you will be able to [add](#adding-a-formula) or [update](#updating-a-formula) a formula.

## Adding a Formula

With a bit of work, you can create a Formula for it. The document [Adding A Formula](https://docs.brew.sh/Adding-Software-to-Homebrew) will help you create, test, and submit a new Formula to us.

## Updating a Formula

Notice an application that's out-of-date in homebrew-coatl-dev Formula? In most cases, it's very simple to update it. We have a command that will accept a new version number and take care of updating the Formula file and submitting a pull request to us.

If updating `ignition`, check if the same upgrade has been already submitted by [searching the open pull requests for `ignition`](https://github.com/coatl-dev/homebrew-coatl-dev/pulls?utf8=✓&q=is%3Apr+is%3Aopen+ignition).

Example for `ignition` (a.k.a. `ignition@8.1`):

```sh
brew bump-formula-pr --url <URL> --sha256 <SHA> --version 8.1.x ignition
```

Example for Ignition 7.9:

```sh
brew bump-formula-pr --url <URL> --sha256 <SHA> ignition@7.9
```
