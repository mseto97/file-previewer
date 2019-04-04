# COSC346 - Assignment 2

Assignment specifications can be found in cosc-346-asgn2-specifications.pdf file included in repository. 

## Files can only be imported if it has a .json file extension. JSON files need to follow file requirements listed below. 

## JSON File and Metadata
The metadata will be described using the following pattern:

    [
      {
        "fullpath": "/path/to/foobar.ext",
        "type": "image|video|document|audio",
        "metadata": {
          "key1": "value1",
          "key2": "value2",
          …
        }
      },
      {
        "fullpath": "/path/to/foobar2.ext",
        "type": "image|video|document|audio",
        "metadata": {
          "key1": "value1",
          "key2": "value2",
          …
        }
      }
    ]

* the type will be one of those given strings (i.e. either an `image`, `video`, `document` or `audio`)
* the metadata key/value pairs will always be a string value
* each of these top-level dictionaries will always contain both a `fullpath` and a media `type`

### Metadata Requirements
There are also some specific requirements for the different media types' metadata as shown in the list below. For example, 
an `image` file type *must* have `creator` and `resolution` metadata associated with it.

* image: creator, resolution, 
* video: creator, resolution, runtime
* document: creator
* audio: creator, runtime
# file-previewer
