# Variáveis de configuração do Docker
docker_image := "ghcr.io/xu-cheng/texlive-full:latest"
project_path := justfile_directory()
tex_files := 'chatgpt claude gemini perplexity'

alias b := build
alias bc := buildconvert
alias c := clean
alias r := run
alias ls := list
alias help := list

[default]
list:
    @just --list

buildconvert filename: (build filename) && (png filename)

build filename *args="-v": && (png filename)
    @just _docker "arara {{args}} {{filename}}.tex"

png filename: _check_imagemagick_convert
    convert -density 300 "{{filename}}.pdf" -flatten -quality 90 "assets/gen/{{filename}}.png"

# Limpa arquivos gerados
clean *args:
    @just _docker "latexmk -c {{args}}"

# Executa qualquer comando arbitrário no container
run +args:
    @just _docker "{{args}}"


# Função auxiliar para rodar comandos no container
[private]
_docker *cmd: _check_docker
    docker run -i --rm \
        -v "{{project_path}}:/data" \
        -v "/var/run/docker.sock:/var/run/docker.sock" \
        -w "/data" \
        "{{docker_image}}" \
        /bin/bash -eo pipefail -c -- \
        "{{cmd}}"

[private]
_check_docker:
    @if ! command -v docker >/dev/null 2>&1; then \
        echo "Docker não encontrado."; \
        echo "Instale seguindo: https://docs.docker.com/engine/install/"; \
        exit 1; \
    fi; \
    if ! docker info >/dev/null 2>&1; then \
        echo "Docker está instalado, mas o daemon não parece estar em execução."; \
        echo "Inicie com: sudo systemctl start docker (Debian/Ubuntu/Fedora)"; \
        exit 1; \
    fi;

[private]
_check_imagemagick_convert:
    @if ! command -v convert >/dev/null 2>&1; then \
        echo "ImageMagick (convert) não encontrado."; \
        echo "Instale com: sudo apt install imagemagick (Debian/Ubuntu) ou sudo dnf install ImageMagick (Fedora)."; \
        exit 1; \
    fi;
