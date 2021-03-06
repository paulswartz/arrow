# Fail if any command fails
set -e

ELIXIR_VERSION=1.9.1
ERLANG_VERSION=22.1.7
NODEJS_VERSION=13.1

change-phantomjs-version 2.1.1
nvm install $NODEJS_VERSION --latest-npm

export ERL_HOME="${SEMAPHORE_CACHE_DIR}/.kerl/installs/${ERLANG_VERSION}"

if [ ! -d "${ERL_HOME}" ]; then
    mkdir -p "${ERL_HOME}"
    KERL_BUILD_BACKEND=git kerl build $ERLANG_VERSION $ERLANG_VERSION
    kerl install $ERLANG_VERSION $ERL_HOME
fi

. $ERL_HOME/activate

if ! kiex use $ELIXIR_VERSION; then
    kiex install $ELIXIR_VERSION
    kiex use $ELIXIR_VERSION
fi

mix local.hex --force
mix local.rebar --force
mix deps.get

npm --prefix assets ci
