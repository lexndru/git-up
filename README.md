# Git Up!
A minimalistic wrapper for Git procedures (`init`, `status`, `push`).

**Note**: developed for Ubuntu systems; other systems might not work out of the box.


## Install from sources
```
$ make install
$ git-up enable
```


## Features
- Choose `user.email` and `user.name` during the repository initialization procedure;
- Create `.gitignore` file and an optional `README.md` file with a dummy title;
- Display information about the repository and the committer;
- Allows different SSH keys to be used across multiple repositories;
- Integrates with command line `git`.


## License
Copyright (c) 2019 Alexandru Catrina <alex@codeissues.net>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
