For my own personal use but may serve as an example of sorts for setting up basic Docker containers and self-hosted Azure CI agents for Qt development. Specifically aimed at [PokemonAutomation's toolchain](https://github.com/PokemonAutomation/Arduino-Source).

If you want to use this, provide your own `.env` file and run `docker compose up -d` inside the `*-agent` directory. Pre-built images available on Docker Hub (pulled by default).

If you want to build your own locally, run `docker compose up -d --build` after adding `build: .` before `image:` in `docker-compose.yml`
