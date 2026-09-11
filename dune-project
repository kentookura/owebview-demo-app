(lang dune 3.24)

(name demo-app)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name <author@example.com>")

(maintainers "Maintainer Name <maintainer@example.com>")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name demo-app)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml owebview brr pure-html htmlact webs htmlit more routes)
 (tags
  ("add topics" "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
