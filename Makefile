.PHONY: help build up down restart shell logs clean test

# Default target
help:
	@echo "SAM 3D Objects - Docker Development Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build      - Build the Docker image"
	@echo "  up         - Start the container in detached mode"
	@echo "  down       - Stop and remove the container"
	@echo "  restart    - Restart the container"
	@echo "  shell      - Open a bash shell in the container"
	@echo "  logs       - Show container logs"
	@echo "  clean      - Remove container, image, and volumes"
	@echo "  test       - Run a simple test to verify the environment"
	@echo ""

# Build the Docker image
build:
	docker-compose build

# Start the container
up:
	docker-compose up -d
	@echo ""
	@echo "Container started! Connect with: make shell"

# Stop the container
down:
	docker-compose down

# Restart the container
restart: down up

# Open a shell in the container
shell:
	docker-compose exec sam3d-dev mamba run -n sam3d-objects bash

# Show logs
logs:
	docker-compose logs -f

# Clean up everything
clean:
	docker-compose down -v
	docker rmi sam3d-objects:dev 2>/dev/null || true
	@echo "Cleanup complete"

# Test the environment
test:
	docker-compose exec sam3d-dev mamba run -n sam3d-objects python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA Available: {torch.cuda.is_available()}')"
