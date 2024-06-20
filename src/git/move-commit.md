# Fix a Commit before Creating a New Branch

**2024-06-20** jms1

Our official workflow at `$DAYJOB` is to commit all work to a ticket-specific feature branch, and then create a pull request to get it merged into the primary branch. This allows people *other than yourself* to review your work before it gets merged into the main code.

I'm not perfect, sometimes I forget to create a new branch first, and accidentally create commits directly on the primary branch. Usually I realize this *before* pushing anything, which means I can fix it on the local machine first.

### Quick Explanation

What we're going to do is this:

* Create the new branch, pointing to the last of the new commits.

* Move the `main` branch to point to what it *was* pointing at before we started creating commits.

## Starting Condition

In this examples below, we're going to assume that the recent commits in the repo look like this:

```
$ git tree1 -a
* 67f8356 (HEAD -> main, origin/main) 2024-06-20 jms1(G) ABC-123 typo
* 8a837d6 2024-06-20 jms1(G) ABC-123 new feature
*   1d3158c 2024-06-13 jms1(G) Merge branch 'ABC-101-previous-feature'
|\
| * d60b020 (origin/ABC-101-previous-feature) 2024-06-12 jms1(G) ABC-101 previous feature
|/
* 3accd26 2024-05-29 jms1(G) ABC-93 old feature
```

> &#x2139;&#xFE0F; `git tree1`
>
> This is one of my standard [git aliases](aliases.md).

In this case, I created two commits, `8a837d6` then `67f8356`, then realized I should have created a feature branch for it first.

## Create the new branch

Part of what you need to accomplish is creating a new branch, pointing to what *should be* the HEAD of that branch. Luckily, the current HEAD is *already* pointing to that commit, so if we just create the new branch here, we'll be good.

```
$ git branch ABC-123-new-feature
```

Looking at the repo after this, you can see that the new "`ABC-123-new-feature`" branch exists and is pointing to the correct commit.

```
$ git tree1 -a
* 67f8356 (HEAD -> main, origin/main, ABC-123-new-feature) 2024-06-20 jms1(G) ABC-123 typo
* 8a837d6 2024-06-20 jms1(G) ABC-123 new feature
*   1d3158c 2024-06-13 jms1(G) Merge branch 'ABC-101-previous-feature'
|\
| * d60b020 (origin/ABC-101-previous-feature) 2024-06-12 jms1(G) ABC-101 previous feature
|/
* 3accd26 2024-05-29 jms1(G) ABC-93 old feature
```

## Move the `main` branch

This will "move" the head of the `main` branch to point to the commit that it had before we started working.

### Identify the commit where the branch *should* point

First, identify the commit that it *should* be pointing to.

In this example, it should be pointing to commit `1d3158c`. You can refer to the commit using its hash, or using any other branch or tag name which points to that commit. In many cases, `origin/main` will be usable.

### Check out the `main` branch

```
$ git checkout main
```

At this point the repo will look like this:

```
$ git tree1 -a 67f8356
* 67f8356 (HEAD -> main, origin/main, ABC-123-new-feature) 2024-06-20 jms1(G) ABC-123 typo
* 8a837d6 2024-06-20 jms1(G) ABC-123 new feature
*   1d3158c 2024-06-13 jms1(G) Merge branch 'ABC-101-previous-feature'
|\
| * d60b020 (origin/ABC-101-previous-feature) 2024-06-12 jms1(G) ABC-101 previous feature
|/
* 3accd26 2024-05-29 jms1(G) ABC-93 old feature
```

In this particular example we were already on the `main` branch, so *in this case* this wasn't really necessary. However, you should get in the habit of using `git checkout` first, since that controls which branch `git reset` will be modifying.

### Move the `main` branch

The `git reset` command changes what the *current* branch points to.

```
$ git reset --hard 1d3158c
```

At this point the repo will look like this:

```
$ git tree1 -a 67f8356
* 67f8356 (origin/main, ABC-123-new-feature) 2024-06-20 jms1(G) ABC-123 typo
* 8a837d6 2024-06-20 jms1(G) ABC-123 new feature
*   1d3158c (HEAD -> main) 2024-06-13 jms1(G) Merge branch 'ABC-101-previous-feature'
|\
| * d60b020 (origin/ABC-101-previous-feature) 2024-06-12 jms1(G) ABC-101 previous feature
|/
* 3accd26 2024-05-29 jms1(G) ABC-93 old feature
```

As you can see ...

* The `main` branch now points to the commit that it *would* have pointed to if we had created the new branch before creating any commits.

* The new `ABC-123-new-feature` branch points to the most recent commit in the work you've already done.

## Keep working

At this point, the problem is fixed. You can continue working as if you *had* created the branch before starting, including pushing the new branch to a remote and creating a pull request.

# Changelog

### 2024-06-20 jms1

* Created page (from notes when I actually made this mistake)
