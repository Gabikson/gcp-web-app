FROM gcr.io/cloud-builders/kubectl

COPY kubectl.bash /builder/kubectl.bash

RUN apt-get -y update && apt-get -y install gettext-base \
    && chmod +x /builder/kubectl.bash

ENTRYPOINT ["/builder/kubectl.bash"]

