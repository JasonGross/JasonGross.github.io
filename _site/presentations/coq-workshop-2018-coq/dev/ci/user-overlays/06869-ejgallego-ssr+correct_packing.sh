if [ "$CI_PULL_REQUEST" = "6869" ] || [ "$CI_BRANCH" = "ssr+correct_packing" ]; then

    Equations_CI_BRANCH=ssr+correct_packing
    Equations_CI_GITURL=https://github.com/ejgallego/Coq-Equations

    ltac2_CI_BRANCH=ssr+correct_packing
    ltac2_CI_GITURL=https://github.com/ejgallego/ltac2

    Elpi_CI_BRANCH=ssr+correct_packing
    Elpi_CI_GITURL=https://github.com/ejgallego/coq-elpi.git

fi
