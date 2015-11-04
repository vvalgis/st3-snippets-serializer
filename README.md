# Snippets serializer for Sublime Text 3

Automatically creates snippets files using snippet description from yaml file.


## Install

**Prerequisites**: ruby >= 2 installed

```bash
git clone ssh://git@github.com:vvalgis/st3-snippets-serializer  
cd st3-snippets-serializer  
bundle install  
```

## Usage

Create yaml file with snippets descriptions for some group. For example file `racket-snippets.yml` with couple of snippets for Racket:

```yaml
---
if:
  scope: racket
  tab: if
  desc: if expression
  content: |+
    (if (${1:predicate})
      ${2:consequent}
      ${3:alternative})
callproc:
  scope: racket
  tab: cc
  desc: Call some procedure
  content: |+
    (${1:name} ${2:argument})
```

**Impotant**: keep `|+` for `content key

To **install** snippets run  
`ruby snippets.rb install racket-snippets.yml`

its create directory in `Packages/User/racket-snippets` and place there files with snippets

**Important**: works only for osx platform. If you use a different platform, you need to set the default path in snippets.rb for your platform.

To **remove** snippets run  
`ruby snippets.rb clean racket-snippets.yml`

its remove directory `Packages/User/racket-snippets`

To **serialize** existing directory with snippets run

`ruby snippets.rb serialize racket-snippets.yml racket-snippets`

its gets all files from `Packages/User/racket-snippets` with extension `sublime-snippet` and put them into `racket-snippets.yml` file in current directory

**Important**: works only for osx platform. If you use different platform, you need to set the default path in snippets.rb for your platform.

## Testing

`ruby tests.rb`

## TODO

Implement serializer to collect snippets to yaml file.

## Author
[vvalgis](https://github.com/vvalgis)

## License

MIT
