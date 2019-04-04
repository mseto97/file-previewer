## FILE-PREVIEWER
file-previewer allows you to import .json file extensions in the format below and preview its contents and add metadata and notes through a UI. You will be able to files with extensions: txt, pdf, mov, m4a, png and jpg. These files will need to follow the JSON file format specified below. 
Assignment specification and assignment report pdfs can be found in this repository.

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
* (an example json file is in the repository as library-contents.json)

### Metadata Requirements
There are also some specific requirements for the different media types' metadata as shown in the list below. For example, 
an `image` file type *must* have `creator` and `resolution` metadata associated with it.
* image: creator, resolution, 
* video: creator, resolution, runtime
* document: creator
* audio: creator, runtime

## Loading Files into the program
A file containing appropriate metadata is in this repostitory. When you run the MediaApp.xcodproj build and run the app (If you are unable to build/run the app, click the "Scheme" button in the top left corner, click "Add New Scheme..." and select "MediaApp". You should now be able to build and run it)  When the app is running, click "Import Files..." button and import "library-contents.json". This will load a prepared json file and its contents into the app where you will be able to view the files. You can import your own files, as long as it follows the given json file format above. 

## Contributors
Daniela Lemow (danielalemow)
Megan Seto (mseto97)
