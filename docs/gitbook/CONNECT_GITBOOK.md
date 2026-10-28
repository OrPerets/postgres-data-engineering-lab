# Connect the student documentation to GitBook

The course documentation lives under `docs/gitbook/`. It includes `README.md`, `SUMMARY.md`, six lab tutorials, troubleshooting and a glossary. **Only student-facing content belongs here.**

## Recommended setup

1. Open [GitBook](https://app.gitbook.com/) and create a new docs site / space named `Data Engineering — Hands-on Course`.
2. In that space, use **Set up Git Sync** and authorize the GitBook GitHub app for the desired repository.
3. Select `OrPerets/postgres-data-engineering-lab` and the branch you intend to synchronize.
4. If GitBook's setup offers a **content root / folder selection**, select `docs/gitbook/`. Confirm the preview lists only tutorial pages and not the repository's `instructor/` directories.
5. If your GitBook plan or Git Sync flow cannot restrict the import to that folder, **do not sync the whole course repository**. Instead, create a separate student-docs repository and copy only these Markdown files there, then sync that repository.
6. Choose initial direction **GitHub → GitBook**. Review the resulting pages, navigation and visibility settings before publishing.
7. Set the audience appropriately. Publishing publicly exposes the selected documentation. For restricted student access, review available GitBook paid audience controls before publishing.

Official docs: [Import with Git Sync](https://gitbook.com/docs/guides/editing-and-publishing-documentation/import-or-migrate-your-content-to-gitbook-with-git-sync) and [Publishing docs](https://gitbook.com/docs/guides/editing-and-publishing-documentation/complete-guide-to-publishing-docs-gitbook).

**Security:** This code repository currently contains instructor solution files. Folder organization alone does not make them private from repository readers. Never grant students repo read access before relocating solutions and addressing their Git history. A GitBook site that shows only student guides does not fix repository permissions.
