# ULMA

## API

    `ulma TOOLKIT PARAMETERS`

## Core API
The core API manages the usage of any language model toolkit supported by ULMA.

    `<toolkit> INPUT_FILE [OPTIONS] OUTPUT_FILE`

### Input file
Provide a text file with one sentence per line.

### Options
ULMA supports a range of options, e.g. for smoothing.
Please be aware, that not all toolkits are compatible with every smoothing method, have a look at our [compatibility list](TODO) to see what's possible.

#### Smoothing method
By default, if no smoothing was set, the unsmoothed MLE will be used.

Smoothing methods ULMA currently supports:
* Kneser Ney `-kn`
* Modified Kneser Ney `-mkn` (implies the interpolation option)

>You can only use one smoothing method per call.

#### Smoothing options
* `-i` use interpolation
* `-seos` enable start-/end-of-sentence tags

>Do we need to enable backoff or is this the default behavior?

### Output file
Existing files won't be overridden without a warning.

The file format depends on the toolkit that is used behind the scenes.

#### File format
* OpenGRM: FST
* other toolkits: ARPA

