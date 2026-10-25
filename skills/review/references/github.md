# Posting a review to GitHub

Only after the user has said to, and only as a **pending** review. They submit
it: it goes out under their name, and the last look should be theirs.

## The quirks, learned the hard way

**One pending review per person.** If they already started one - a comment left
in the browser - creating another fails. Check first, and add to the one that
exists rather than replacing it:

```bash
gh api repos/<owner>/<repo>/pulls/<number>/reviews --jq '.[] | select(.state == "PENDING") | {id, user: .user.login}'
```

**A pending review's body cannot be set before submitting.** Both the REST and
GraphQL calls refuse it with "Could not edit a review with a missing body". The
summary is typed into the box at submit time, so write it out and hand it over
as text for them to paste, rather than trying to attach it.

**Line comments go on through GraphQL** when adding to an existing pending
review. `pullRequestReviewId` is the node id, not the number from the REST call:

```bash
gh api graphql -f query='mutation($r:ID!,$p:String!,$b:String!,$l:Int!){
  addPullRequestReviewThread(input:{pullRequestReviewId:$r,path:$p,body:$b,line:$l,side:RIGHT}){thread{id}}
}' -f r=<review-node-id> -f p=<path> -f b=<body> -F l=<line>
```

For a comment about a whole file, drop `line` and pass `subjectType: FILE`.

**Resolving an old round** is its own mutation, and threads do not resolve
themselves when the code changes - they only go grey as "outdated", which
leaves the author guessing which ones still apply:

```bash
gh api graphql -f query='mutation($t:ID!){resolveReviewThread(input:{threadId:$t}){thread{id isResolved}}}' -f t=<thread-node-id>
```

List them first with `reviewThreads(first:50){nodes{id isResolved isOutdated comments(first:1){nodes{databaseId path line body}}}}`.
Withdrawing a comment rather than resolving it silently means replying first -
`POST /pulls/<n>/comments/<comment-databaseId>/replies` - so the record says
why it no longer applies.

**The line number is the line in the new file**, as the diff shows it. REST
reports `line: null` for comments in a pending review, which looks like they
failed to anchor - they did not. Check with GraphQL instead:

```bash
gh api graphql -f query='{node(id:"<review-node-id>"){... on PullRequestReview{comments(first:50){nodes{path line subjectType}}}}}'
```

**Starting a review from scratch**, when there is no pending one. Leave
`event` out entirely - `PENDING` is not one of its values and passing it is a
422, "Variable $event of type PullRequestReviewEvent was provided invalid
value". A review created with no event *is* pending. `body` cannot be set
either, so send nothing but an empty comment list:

```bash
gh api repos/<owner>/<repo>/pulls/<number>/reviews --method POST --input - <<'JSON'
{"comments": []}
JSON
```

Keep the `node_id` from the response; the line comments below need it.

## Writing the comments

One finding per comment, on the line it is about. Say what breaks and what to do
instead; the reasoning belongs in the comment, not in a follow-up conversation.

Findings that have no single line - merge order, a missing description, anything
about the change as a whole - go in the summary text rather than being pinned to
an unrelated line.

Tell the user afterwards what went where, so they can read the comments in the
browser without opening every file.
