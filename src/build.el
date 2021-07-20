(require 'seq)
(require 'org)
(require 'ob-tangle)
(require 'ox-org)

(org-babel-tangle-file (elt argv 0))
