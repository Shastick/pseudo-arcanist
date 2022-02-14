# Pseudo Arc

For [phabricator/arcanist](https://www.phacility.com/phabricator/) refugees.

## Misc

I've enjoyed working with Phabricator for the last 8 years, and believe that its conventions and the mindset it imparted me
are valuable. These can be transposed quite easily to most available Git hosting solutions with a tiny bit of tooling.

This repo aims at providing such tools.

Note that this is a work in progress. Suggestions welcome.

## TOC 

 - [Gitlab Bash Scripts](bash/gitlab) - `glab` based shell scripts to emulate `arc diff` and `arc land`

## Commit Message Templates

Note that to get the full phab+arc experience you'll probably want to enforce squash + rebase
and have a commit message template such as:

```
%{title}

Summary:
%{description}

%{approved_by}

Merged By: %{merged_by}

Revision: %{url}
```

## How/When does linting happen?

My current (and at the moment favourite) alternative to `arc lint` is [pre-commit](https://pre-commit.com/).

It plugs itself into whichever git hook you prefer, which is not perfect but good enough, and has [extensive linter integrations](https://pre-commit.com/hooks.html)
out of the box.

### Gitlab 

In Gitlab, you can set the template in `Settings` -> `General` -> `Merge Requests`.

## Future Plans

- Github integration
- Rust or Go based implementation
