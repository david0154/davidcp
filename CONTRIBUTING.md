# David Control Panel - Contribution Guidelines

## Ways to contribute

- **Beta testing**:
  - Download and install builds from the `beta` branch. If you encounter an issue with a beta build, file an issue report on [GitHub](https://www.github.com/david0154/davidcp/issues).<br>
    `v-update-sys-david-git davidcp beta install` will install the latest beta build from our GitHub repository.
- **Code review and bug fixes**:
  - Read over the code and if you notice errors (even spelling mistakes), submit a pull request with your changes.
- **New features**:
  - Is there an awesome feature that you'd love to see included? Submit a pull request with your changes, and if approved your PR will be reviewed and merged for inclusion in an upcoming release. While our development team tries to accommodate all reasonable requests please remember that it does take time to develop, implement and test new features and as such we may not be able to fulfill all requests or may have to put a feature on backlog for a later date.

## Development Guidelines

Additional information on how to contribute to David Control Panel can be found in the [Development](docs/docs/contributing/development.md) documentation.

### Code formatting and comments

We ask that you follow existing naming schemes and coding conventions where possible, and that you add comments in your source code where appropriate to aid other developers in debugging and understanding your code in the future.

To ensure your changes meet our formatting requirements, please run `npm install` from the root of the repository before committing your changes. This will set up pre-commit hooks for automatic formatting, which will help to get your changes merged as quickly as possible.

### Workflow and process

Development for this project takes place in branches to effectively develop, manage, and test new features and code changes. Our tiered approach allows us to closely control the quality of code as it is checked in for inclusion.

We have three primary or "evergreen" branches, which exist throughout our product's lifetime. Please refer to the following table for a description:

| Branch    |                                                                          Description                                                                           |
| --------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| `main`    |              Contains a snapshot of the latest development code.<br>**Not intended for production use and contains code from a merge snapshot.**               |
| `beta`    | Contains a snapshot of the next version which is currently in testing.<br>**Not intended for production use, however code from this branch should be stable.** |
| `release` |     Contains a snapshot of the latest stable release.<br>**Intended for production use. This repository contains the same code as our compiled packages.**     |

### Creating a new branch and submitting pull requests

The first step is to create a fork of the `davidcp/davidcp` repository under your GitHub account so that you may submit pull requests and patches.

Once you've created your fork, clone the repository to your computer and make sure that you've checked out the `main` branch. **Always** create a new topic branch for your work.

### Branch naming convention

- **Prefix:** `topic/` (such as **fix**, **feature**, **refactor**, etc.)
- **ID**: `888` (GitHub Issue ID if an issue exists)
- **Title:** `my-awesome-patch`

Branch name examples:

- `feature/777-my-awesome-new-feature` or `feature/my-other-new-feature`
- `fix/000-some-bug-fix` or `fix/this-feature-is-broken`
- `refactor/v-change-domain-owner`
- `test/mail-domain-ssl`

### Squashing commits for smaller changes

To aid other developers and keep the project's commit history clean, please **squash your commits** when it's appropriate. For example with smaller commits related to the same piece of code, such as commits labelled "Fixed item 1", "Adjusted color of button XYZ", "Adjusted alignment of button XYZ" can be squashed into one commit with the title "Fixed button issues in item".

### What happens when I submit a pull request?

- Our internal development team will review your work and validate your request.
- Your changes will be tested to ensure that there are no issues.
- If changes need to be made, you will be notified via GitHub.
- Once approved, your code will be merged for inclusion in an upcoming release of David Control Panel.

All pull requests must include a brief but descriptive title, and a detailed description of the changes that you've made. **Only include commits that are related to your feature, bug fix, or patch in your pull request!**

## Thank you

We appreciate **all** contributions no matter what size; your feedback and input directly shapes the future of David Control Panel and we could not do it without your support.

Thank you for your time and we look forward to seeing your pull requests,<br>
The David Control Panel development team
