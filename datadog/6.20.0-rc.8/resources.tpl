apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: {{ .AgentName }}
  labels:
    shipa.io/is-shipa-datadog: "true"
rules:
  -
    apiGroups:
      - ""
    resources:
      - services
      - events
      - endpoints
      - pods
      - nodes
      - componentstatuses
    verbs:
      - get
      - list
      - watch
  -
    apiGroups:
      - quota.openshift.io
    resources:
      - clusterresourcequotas
    verbs:
      - get
      - list
  -
    apiGroups:
      - ""
    resourceNames:
      - datadogtoken
      - datadog-leader-election
    resources:
      - configmaps
    verbs:
      - get
      - update
  -
    apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - create
  -
    nonResourceURLs:
      - /version
      - /healthz
      - /metrics
    verbs:
      - get
  -
    apiGroups:
      - ""
    resources:
      - nodes/metrics
      - nodes/spec
      - nodes/proxy
      - nodes/stats
    verbs:
      - get
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: {{ .AgentName }}
  namespace: {{ .Namespace }}
  labels:
    shipa.io/is-shipa-datadog: "true"
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: {{ .AgentName }}
  labels:
    shipa.io/is-shipa-datadog: "true"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ .AgentName }}
subjects:
  - kind: ServiceAccount
    name: {{ .AgentName }}
    namespace: {{ .Namespace }}
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: {{ .SecretName }}
  namespace: {{ $.Namespace }}
  labels:
    shipa.io/is-shipa-datadog: "true"
data:
  api-key: {{ $.Key }}
---
# APP Key
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: {{ .AgentName }}
  namespace: {{ $.Namespace }}
  labels:
    shipa.io/is-shipa-datadog: "true"
data:
  api-key: {{ $.Key }}
---
# Source: datadog/templates/system-probe-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .AgentName }}-system-probe-config
  namespace: {{ $.Namespace }}
  labels:
    shipa.io/is-shipa-datadog: "true"
data:
  system-probe.yaml: |
    system_probe_config:
      enabled: true
      debug_port:  0
      sysprobe_socket: /opt/datadog-agent/run/sysprobe.sock
      enable_conntrack : true
      bpf_debug: false
---
# Source: datadog/templates/system-probe-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .AgentName }}-security
  namespace: {{ $.Namespace }}
  labels:
    shipa.io/is-shipa-datadog: "true"
data:
  system-probe-seccomp.json: |
    {
      "defaultAction": "SCMP_ACT_ERRNO",
      "syscalls": [
        {
          "names": [
            "accept4",
            "access",
            "arch_prctl",
            "bind",
            "bpf",
            "brk",
            "capget",
            "capset",
            "chdir",
            "clock_gettime",
            "clone",
            "close",
            "connect",
            "copy_file_range",
            "creat",
            "dup",
            "dup2",
            "dup3",
            "epoll_create",
            "epoll_create1",
            "epoll_ctl",
            "epoll_ctl_old",
            "epoll_pwait",
            "epoll_wait",
            "epoll_wait",
            "epoll_wait_old",
            "execve",
            "execveat",
            "exit",
            "exit_group",
            "fchmod",
            "fchmodat",
            "fchown",
            "fchown32",
            "fchownat",
            "fcntl",
            "fcntl64",
            "fstat",
            "fstat64",
            "fstatfs",
            "fsync",
            "futex",
            "getcwd",
            "getdents",
            "getdents64",
            "getegid",
            "geteuid",
            "getgid",
            "getpeername",
            "getpid",
            "getppid",
            "getpriority",
            "getrandom",
            "getresgid",
            "getresgid32",
            "getresuid",
            "getresuid32",
            "getrlimit",
            "getrusage",
            "getsid",
            "getsockname",
            "getsockopt",
            "gettid",
            "gettimeofday",
            "getuid",
            "getxattr",
            "ioctl",
            "ipc",
            "listen",
            "lseek",
            "lstat",
            "lstat64",
            "mkdir",
            "mkdirat",
            "mmap",
            "mmap2",
            "mprotect",
            "munmap",
            "nanosleep",
            "newfstatat",
            "open",
            "openat",
            "pause",
            "perf_event_open",
            "pipe",
            "pipe2",
            "poll",
            "ppoll",
            "prctl",
            "prlimit64",
            "pselect6",
            "read",
            "readlink",
            "readlinkat",
            "recvfrom",
            "recvmmsg",
            "recvmsg",
            "rename",
            "restart_syscall",
            "rmdir",
            "rt_sigaction",
            "rt_sigpending",
            "rt_sigprocmask",
            "rt_sigqueueinfo",
            "rt_sigreturn",
            "rt_sigsuspend",
            "rt_sigtimedwait",
            "rt_tgsigqueueinfo",
            "sched_getaffinity",
            "sched_yield",
            "seccomp",
            "select",
            "semtimedop",
            "send",
            "sendmmsg",
            "sendmsg",
            "sendto",
            "set_robust_list",
            "set_tid_address",
            "setgid",
            "setgid32",
            "setgroups",
            "setgroups32",
            "setns",
            "setrlimit",
            "setsid",
            "setsidaccept4",
            "setsockopt",
            "setuid",
            "setuid32",
            "sigaltstack",
            "socket",
            "socketcall",
            "socketpair",
            "stat",
            "stat64",
            "statfs",
            "sysinfo",
            "umask",
            "uname",
            "unlink",
            "unlinkat",
            "wait4",
            "waitid",
            "waitpid",
            "write"
          ],
          "action": "SCMP_ACT_ALLOW",
          "args": null
        },
        {
          "names": [
            "setns"
          ],
          "action": "SCMP_ACT_ALLOW",
          "args": [
            {
              "index": 1,
              "value": 1073741824,
              "valueTwo": 0,
              "op": "SCMP_CMP_EQ"
            }
          ],
          "comment": "",
          "includes": {},
          "excludes": {}
        }
      ]
    }
---
# Source: datadog/templates/daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ .AgentName }}
  namespace: {{ $.Namespace }}
  labels:
    shipa.io/is-shipa-datadog: "true"
spec:
  selector:
    matchLabels:
      app: {{ .AgentName }}
  template:
    metadata:
      labels:
        app: {{ .AgentName }}
      name: {{ .AgentName }}
      annotations:
        container.apparmor.security.beta.kubernetes.io/system-probe: unconfined
        container.seccomp.security.alpha.kubernetes.io/system-probe: localhost/system-probe
    spec:
      containers:
        - name: agent
          image: "datadog/agent:7.19.0"
          imagePullPolicy: IfNotPresent
          command: ["agent", "start"]
          resources: {}
          ports:
            - containerPort: 8125
              name: dogstatsdport
              protocol: UDP
          env:
            - name: DD_API_KEY
              valueFrom:
                secretKeyRef:
                  name: "{{ .AgentName }}"
                  key: api-key
            - name: DD_KUBERNETES_KUBELET_HOST
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
            - name: KUBERNETES
              value: "yes"
            - name: DOCKER_HOST
              value: unix:///host/var/run/docker.sock
            - name: DD_LOG_LEVEL
              value: "INFO"
            - name: DD_DOGSTATSD_PORT
              value: "8125"
            - name: DD_APM_ENABLED
              value: "false"
            - name: DD_LOGS_ENABLED
              value: "true"
            - name: DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL
              value: "true"
            - name: DD_LOGS_CONFIG_K8S_CONTAINER_USE_FILE
              value: "true"
            - name: DD_HEALTH_PORT
              value: "5555"
            - name: SYSTEM_PROBE_CONFIG_SYSPROBE_SOCKET
              value: /sysprobe/var/run
          volumeMounts:
            - name: config
              mountPath: /etc/datadog-agent
            - name: runtimesocketdir
              mountPath: /host/var/run
              readOnly: true
            - name: sysprobe-socket-dir
              mountPath: /sysprobe/var/run
              readOnly: true
            - name: procdir
              mountPath: /host/proc
              readOnly: true
            - name: cgroups
              mountPath: /host/sys/fs/cgroup
              readOnly: true
            - name: pointerdir
              mountPath: /opt/datadog-agent/run
            - name: logpodpath
              mountPath: /var/log/pods
              readOnly: true
            - name: logdockercontainerpath
              mountPath: /var/lib/docker/containers
              readOnly: true
          livenessProbe:
            failureThreshold: 6
            httpGet:
              path: /health
              port: 5555
            initialDelaySeconds: 15
            periodSeconds: 15
            successThreshold: 1
            timeoutSeconds: 5
        - name: trace-agent
          image: "datadog/agent:7.19.0"
          imagePullPolicy: IfNotPresent
          command: ["trace-agent", "-config=/etc/datadog-agent/datadog.yaml"]
          resources: {}
          ports:
            - containerPort: 8126
              hostPort: 8126
              name: traceport
              protocol: TCP
          env:
            - name: DD_API_KEY
              valueFrom:
                secretKeyRef:
                  name: "{{ .AgentName }}"
                  key: api-key
            - name: DD_KUBERNETES_KUBELET_HOST
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
            - name: KUBERNETES
              value: "yes"
            - name: DOCKER_HOST
              value: unix:///host/var/run/docker.sock
            - name: DD_LOG_LEVEL
              value: "INFO"
            - name: DD_APM_ENABLED
              value: "true"
            - name: DD_APM_NON_LOCAL_TRAFFIC
              value: "true"
            - name: DD_APM_RECEIVER_PORT
              value: "8126"
          volumeMounts:
            - name: config
              mountPath: /etc/datadog-agent
            - name: runtimesocketdir
              mountPath: /host/var/run
              readOnly: true
          livenessProbe:
            initialDelaySeconds: 15
            periodSeconds: 15
            tcpSocket:
              port: 8126
            timeoutSeconds: 5
        - name: process-agent
          image: "datadog/agent:7.19.0"
          imagePullPolicy: IfNotPresent
          command: ["process-agent", "-config=/etc/datadog-agent/datadog.yaml"]
          resources: {}
          env:
            - name: DD_API_KEY
              valueFrom:
                secretKeyRef:
                  name: "{{ .AgentName }}"
                  key: api-key
            - name: DD_KUBERNETES_KUBELET_HOST
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
            - name: KUBERNETES
              value: "yes"
            - name: DOCKER_HOST
              value: unix:///host/var/run/docker.sock
            - name: DD_PROCESS_AGENT_ENABLED
              value: "true"
            - name: DD_LOG_LEVEL
              value: "INFO"
            - name: DD_SYSTEM_PROBE_ENABLED
              value: "true"
          volumeMounts:
            - name: config
              mountPath: /etc/datadog-agent
            - name: runtimesocketdir
              mountPath: /host/var/run
              readOnly: true
            - name: cgroups
              mountPath: /host/sys/fs/cgroup
              readOnly: true
            - name: passwd
              mountPath: /etc/passwd
            - name: procdir
              mountPath: /host/proc
              readOnly: true
            - name: sysprobe-socket-dir
              mountPath: /opt/datadog-agent/run
              readOnly: true
        - name: system-probe
          image: "datadog/agent:7.19.0"
          imagePullPolicy: IfNotPresent
          securityContext:
            capabilities:
              add: ["SYS_ADMIN", "SYS_RESOURCE", "SYS_PTRACE", "NET_ADMIN", "IPC_LOCK"]
          command: ["/opt/datadog-agent/embedded/bin/system-probe", "--config=/etc/datadog-agent/system-probe.yaml"]
          env:
            - name: DD_LOG_LEVEL
              value: "INFO"
          resources: {}
          volumeMounts:
            - name: debugfs
              mountPath: /sys/kernel/debug
            - name: sysprobe-config
              mountPath: /etc/datadog-agent
            - name: sysprobe-socket-dir
              mountPath: /opt/datadog-agent/run
            - name: procdir
              mountPath: /host/proc
              readOnly: true
      initContainers:
        - name: init-volume
          image: "datadog/agent:7.19.0"
          imagePullPolicy: IfNotPresent
          command: ["bash", "-c"]
          args:
            - cp -r /etc/datadog-agent /opt
          volumeMounts:
            - name: config
              mountPath: /opt/datadog-agent
          resources: {}
        - name: init-config
          image: "datadog/agent:7.19.0"
          imagePullPolicy: IfNotPresent
          command: ["bash", "-c"]
          args:
            - for script in $(find /etc/cont-init.d/ -type f -name '*.sh' | sort) ; do
              bash $script ; done
          volumeMounts:
            - name: config
              mountPath: /etc/datadog-agent
            - name: procdir
              mountPath: /host/proc
              readOnly: true
            - name: runtimesocketdir
              mountPath: /host/var/run
              readOnly: true
          env:
            - name: DD_API_KEY
              valueFrom:
                secretKeyRef:
                  name: "{{ .AgentName }}"
                  key: api-key
            - name: DD_KUBERNETES_KUBELET_HOST
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
            - name: KUBERNETES
              value: "yes"
            - name: DOCKER_HOST
              value: unix:///host/var/run/docker.sock
          resources: {}
        - name: seccomp-setup
          image: "datadog/agent:7.19.0"
          command:
            - cp
            - /etc/config/system-probe-seccomp.json
            - /host/var/lib/kubelet/seccomp/system-probe
          volumeMounts:
            - name: {{ .AgentName }}-security
              mountPath: /etc/config
            - name: seccomp-root
              mountPath: /host/var/lib/kubelet/seccomp
          resources: {}
      volumes:
        - name: config
          emptyDir: {}
        - hostPath:
            path: /var/run
          name: runtimesocketdir
        - hostPath:
            path: /proc
          name: procdir
        - hostPath:
            path: /sys/fs/cgroup
          name: cgroups
        - name: s6-run
          emptyDir: {}
        - name: sysprobe-config
          configMap:
            name: {{ .AgentName }}-system-probe-config
      - name: {{ .AgentName }}-security
      configMap:
        name: {{ .AgentName }}-security
      - hostPath:
      path: /var/lib/kubelet/seccomp
      name: seccomp-root
      - hostPath:
          path: /sys/kernel/debug
        name: debugfs
      - name: sysprobe-socket-dir
        emptyDir: {}
      - hostPath:
          path: /etc/passwd
        name: passwd
      - hostPath:
          path: "/var/lib/datadog-agent/logs"
        name: pointerdir
      - hostPath:
          path: /var/log/pods
        name: logpodpath
      - hostPath:
          path: /var/lib/docker/containers
        name: logdockercontainerpath
      tolerations:
      affinity: null
      serviceAccountName: "default"
      nodeSelector:
  updateStrategy:
    rollingUpdate:
      maxUnavailable: 10%
    type: RollingUpdate