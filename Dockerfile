FROM python:3.8

ARG USERNAME
ARG USER_UID
ARG USER_GID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && apt-get update \
  && apt-get install -y sudo wget curl git\
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \          
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

# git settings
RUN  mkdir /gitcompletion/ \
  && wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -P /gitcompletion/. \
  && wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -P /gitcompletion/. \
  && SNIPPET="source /gitcompletion/*.sh" \
  && echo "$SNIPPET" >> "/home/$USERNAME/.bashrc"

# Persist bash history
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory \
  && echo "$SNIPPET" >> "/home/$USERNAME/.bashrc"

# make alias
COPY alias.sh /
RUN SNIPPET="source /alias.sh" \
  && chown $USERNAME /alias.sh \
  && echo "$SNIPPET" >> "/home/$USERNAME/.bashrc"

# make PS1
COPY ps1.sh /
RUN SNIPPET="source /ps1.sh" \
  && chown $USERNAME /ps1.sh \
  && echo "$SNIPPET" >> "/home/$USERNAME/.bashrc"

# set non-root user
USER $USERNAME
WORKDIR /workspace

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# install requirements
COPY requirements.txt ./
RUN pip install -r requirements.txt