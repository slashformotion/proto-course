# justfile

watch:
    typst w presentation/slides.typ

build:
    typst compile presentation/slides.typ