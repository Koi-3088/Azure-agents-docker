For my own personal use but may serve as an example of sorts for setting up basic Docker containers and self-hosted Azure CI agents for Qt development. Specifically aimed at [PokemonAutomation's toolchain](https://github.com/PokemonAutomation/Arduino-Source).

If you want to use this, provide your own `.env` file and run `docker compose up -d --force-recreate --build` inside the `*-agent` directory. Pre-built images available on Docker Hub.
