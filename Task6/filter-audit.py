import json
import sys


def is_suspicious(event):
    obj = event.get("objectRef") or {}
    request = event.get("requestObject") or {}
    resource = obj.get("resource")
    verb = event.get("verb")

    if resource == "secrets" and verb in ("get", "list"):
        return True

    if resource == "pods" and obj.get("subresource") == "exec":
        return True

    if resource == "pods" and verb == "create":
        containers = request.get("spec", {}).get("containers", [])
        for container in containers:
            if container.get("securityContext", {}).get("privileged") is True:
                return True

    if resource == "rolebindings" and verb in ("create", "update", "patch"):
        if isinstance(request, dict) and request.get("roleRef", {}).get("name") == "cluster-admin":
            return True

    return "audit-policy" in (event.get("requestURI") or "").lower()


input_file, output_file = sys.argv[1:]
events = []

with open(input_file, encoding="utf-8") as log:
    for line in log:
        if line.strip():
            event = json.loads(line)
            if is_suspicious(event):
                events.append(event)

with open(output_file, "w", encoding="utf-8") as result:
    json.dump(events, result, ensure_ascii=False, indent=2)
