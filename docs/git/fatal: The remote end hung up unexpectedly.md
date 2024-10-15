# fatal: The remote end hung up unexpectedly

```bash
$ git push
Counting objects: 2332669, done.
Delta compression using up to 16 threads.
Compressing objects: 100% (360818/360818), done.
error: RPC failed; result=22, HTTP code = 411
fatal: The remote end hung up unexpectedly
Writing objects: 100% (2332669/2332669), 483.30 MiB | 114.26 MiB/s, done.
Total 2332669 (delta 1949888), reused 2330461 (delta 1949349)
fatal: The remote end hung up unexpectedly
```

只用运行

`git config --global http.postBuffer 157286400`

ref

<https://suleimanabdullah.medium.com/git-larger-file-error-c34e769698a7>

<https://confluence.atlassian.com/bitbucketserverkb/git-push-fails-fatal-the-remote-end-hung-up-unexpectedly-779171796.html>