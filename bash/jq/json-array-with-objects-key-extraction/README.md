# Key exctractions from a json array with objects using jq

This is a simple snippet that will loop thru a `json` object that contains a array with objects. We use `jq` in bash to loop thru the array and extract the keys

### Example

```bash
$ cat ./data.json
[
  {
    "text": "Installing vscode",
    "executable": "vscode",
    "path": "/path/to/vscode"
  },
  {
    "text": "Installing spotify",
    "executable": "spotify",
    "path": "/path/to/spotify"
  },
  {
    "text": "Installing git",
    "executable": "git",
    "path": "/path/to/git"
  }
]

$ ./example.sh
Parsing object 0 in array
 dataText: Installing vscode
 dataExecutable: vscode
 dataPath: /path/to/vscode

Parsing object 1 in array
 dataText: Installing spotify
 dataExecutable: spotify
 dataPath: /path/to/spotify

Parsing object 2 in array
 dataText: Installing git
 dataExecutable: git
 dataPath: /path/to/git
```
