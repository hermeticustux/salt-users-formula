{% for user in pillar['users'] %}
user_{{user.name}}:
  group.present:
    - name: {{user.name}}
    - gid: {{user.gid}}

  user.present:
    - name: {{user.name}}
    - fullname: {{user.fullname}}
    - password: {{user.shadow}}
    - shell: {{user.shell}}
    - uid: {{user.uid}}
    - gid: {{user.gid}}
    {% if user.groups %}
    - optional_groups:
      {% for group in user.groups %}
      - {{group}}
      {% endfor %}
    {% endif %}
    - require:
      - group: user_{{user.name}}

  file.directory:
    - name: /home/{{user.name}}
    - user: {{user.name}}
    - group: {{user.name}}
    - mode: 0751
    - makedirs: True

user_{{user.name}}_forward:
  file.append:
    - name: /home/{{user.name}}/.forward
    - text: {{user.email}}

user_{{user.name}}_sshdir:
  file.directory:
    - name: /home/{{user.name}}/.ssh
    - user: {{user.name}}
    - group: {{user.name}}
    - mode: 0700

{% if 'authkey' in user %}
user_{{user.name}}_authkeys:
  ssh_auth.present:
    - user: {{user.name}}
    - name: {{user.authkey}}
{% endif %}

{% endfor %} # user in users

/etc/sudoers:
  file.managed:
    - source: salt://users/files/sudoers
    - user: root
    - group: root
    - mode: 440
