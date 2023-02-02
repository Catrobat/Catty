This step-by-step guide will support you on your way to your first pull request (PR) at Catrobat. To achieve this, we will guide you through the following steps:
1. Workspace Setup
2. Finding your first Ticket
3. Implementing your first ticket using Catrobat's Contribution Workflow

# 1. Workspace Setup
First, we will show you how to set up your working environment and verify the correctness of this setup.


## a. Installing the IDE and Tools
We recommend using [Xcode](https://developer.apple.com/xcode/) as all our contributors do. Please find the IDE version suitable for your operating system on the website and install it on your computer.

We use SwiftLint to enforce Swift style and conventions. You need to install and use it as all PRs will be checked against style and coding guidelines. We recommend you install the [Homebrew package manager](https://brew.sh/) first. Afterwards, install SwiftLint using the following command:

```diff
brew install swiftlint
```

The following rules are used to lint Swift files for the Catty project:
- [Catty Rules](https://github.com/Catrobat/Catty/blob/master/src/.swiftlint.yml)
- [Catty Rules Autocorrect](https://github.com/Catrobat/Catty/blob/master/src/.swiftlint.auto.yml)


## b. Repository Setup
### (I) Git Setup
At Catrobat, we use Git to keep track of changes in our codebase. If you have not installed Git on your computer yet, please follow the [official guide to set up Git](https://docs.github.com/en/get-started/quickstart/set-up-git).

### (II) Catrobat's Forking Workflow
To enable the contribution of people like you, we decided to use a forking workflow. In a nutshell, this works as follows. First, everyone who wants to contribute creates (=forks) a personal copy of our repository (=fork). The contributor then makes changes on his fork and informs the community about the changes via a PR. A core contributor will review the changes in the PR. If the changes are accepted, the core contributor will merge the changes into the original repository of Catrobat.
If you are unfamiliar with Git or have not used it recently, the official guide about [forking a repository](https://docs.github.com/en/get-started/quickstart/fork-a-repo) is a good starting point.

### (III) Setting up your Fork
Now that you know how to work with Git, it is time to set up your fork by executing the following steps:
- [Fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo#forking-a-repository) the [repository of Catty](https://github.com/Catrobat/Catty)
- Clone the fork:
  - [via Xcode](https://developer.apple.com/documentation/xcode/configuring-your-xcode-project-to-use-source-control), or
  - [via Git Bash](https://docs.github.com/en/get-started/quickstart/fork-a-repo#cloning-your-forked-repository) and open it in your IDE manually
- [Configure synchronisation](https://docs.github.com/en/get-started/quickstart/fork-a-repo#configuring-git-to-sync-your-fork-with-the-original-repository) of your fork


## c. Setup Verification
After you have opened the Catty project in Xcode you can press the "Run" button. The build setting will automatically check if everything is ok and an iPhone simulator displaying our app should open up upon successful completion of the building process.

Note: Do not test with a physical device as the setup and verification process is too complicated at this stage.



# 2. Finding your first Ticket


## a. Catrobat's Jira Workflow
At Catrobat, we use Jira to keep track of all issues (stories, tasks, and bugs) in our projects. You can find the Jira project of Catty [here](https://jira.catrob.at/projects/CATTY/issues/CATTY-683?filter=allopenissues).
If you click "Kanban Board" on the left menu in Jira, you will get an overview of what we are currently working on. You can see that different issues have different statuses (e.g., "Ready for Development"). The collection of all statuses makes up our Jira workflow that transparently shows the project's current state to every team member. You can find an overview of our Jira workflow if you click on an issue and the "(View Workflow)" next to the status field.
It is crucial to follow this workflow to keep the team informed about what you are currently working on.


## b. Choosing a suitable Ticket
We prepared a [pool of beginner tickets](https://jira.catrob.at/projects/PAINTROID/issues/?filter=allopenissues) for our newcomers that should be easy to implement. The tickets are marked with "Experience Level" BEGINNER, and you are free to choose any ticket from this pool that has not been assigned yet ("Status" = "Ready for Development"). Please also check the comments below to find out if another newcomer has already taken the issue!


## c. Informing the Community
As mentioned earlier, it is essential to keep the team updated. As you do not have the permissions for our Jira project yet, you cannot change the status of the issue you chose. Instead, please assign the ticket to yourself by commenting on it using the following template.

```diff
"I am starting to work on this issue. For the next 10 days, this ticket is assigned to me. If I am not able to create a pull request within 10 days, anybody else can take over this issue."
```

After you have finished your work and submitted a pull request, you have to use the following template to request a review from our community:

```diff
"@[Name of the responsible reviewer as mentioned in the beginner ticket] please review my pull request [Link to PR on GitHub (e.g., https://github.com/Catrobat/Catroid/pull/4580)]."
```

💡 In the upcoming steps, you will find the general workflow of the project. As you do not have permissions for Jira and Confluence yet, please skip all actions that involve Jira ticket status updates and additional information on Confluence!



# 3. Catrobat's Contribution Workflow
The general workflow of the project involves the following steps:
- Claim a Ticket
- Do the Work
- Submit the Changes

Please refer to our [contribution guide](https://github.com/Catrobat/Catty/blob/develop/.github/contributing.md) to receive step-by-step guidance throughout your contribution.
