## Prerequisites

Before you begin, please ensure you have the following installed on your system:

- [Docker](https://docs.docker.com/get-docker/)
- [Git](https://git-scm.com/downloads)

## Getting Started

### 1. Clone the Repository

Students can clone the repository using the following command:

```bash
git clone https://github.com/yourusername/cs186A4-docker-setup.git
cd cs186A4-docker-setup
```

### 2. Build the Docker Image
In the project root (where the Dockerfile is located), run:

```bash
docker build -t my-spark-project .
```

### 3. Run the Docker Container
After building the image, run the container:

```bash
docker run -it my-spark-project
```

This will start the container and drop you into a bash shell inside the Docker environment.

### Additional Information
##Project Files:
Your project files are located in the /opt/spark-homework-udf directory within the container.
##Spark Usage:
Use the installed Spark instance by running commands like spark-shell inside the container.
