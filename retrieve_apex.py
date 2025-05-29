import os
import subprocess
import sys
import json

def authenticate():
    # Write the auth url from env secret to a file
    auth_url = ""
    if not auth_url:
        print("Missing SFDX_AUTH_URL environment variable")
        sys.exit(1)
    with open("sfdx-auth.txt", "w") as f:
        f.write(auth_url)

    # Authenticate using sfdx CLI
    result = subprocess.run(["sfdx", "auth:sfdxurl:store", "-f", "sfdx-auth.txt", "-a", "myorg"], capture_output=True)
    if result.returncode != 0:
        print("Authentication failed:", result.stderr.decode())
        sys.exit(1)
    print("Authenticated successfully.")

def retrieve_apex():
    # Make sure manifest/package.xml exists
    if not os.path.exists("manifest/package.xml"):
        print("manifest/package.xml is missing!")
        sys.exit(1)

    # Retrieve Apex classes using sfdx
    result = subprocess.run([
        "sfdx", "force:source:retrieve",
        "-x", "manifest/package.xml",
        "-u", "myorg"
    ], capture_output=True)

    if result.returncode != 0:
        print("Retrieve failed:", result.stderr.decode())
        sys.exit(1)

    print("Apex classes retrieved successfully.")

def main():
    authenticate()
    retrieve_apex()

if __name__ == "__main__":
    main()
