# ULMA
The unified language modeling API wraps various language modeling tools and toolkits.
Thus users can switch between the tools with no effort.

In addition, ULMA comes with an [installation wizard](../install/wizard/ulma-installer.sh) for all these tools.

## Supported toolkits
Currently ULMA supports

| Name | Toolkit value |
| ---- | ------------ |
| [KenLM](http://kheafield.com/code/kenlm/) | `kenlm` |
| [Kylm](http://www.phontron.com/kylm/) | `kylm` |
| [SRILM](http://www.speech.sri.com/projects/srilm/) | `srilm` |

## Endpoints
There is a central API endpoint `ulma.sh` that can use any of the toolkits supported by ULMA.
Simply pass the toolkit you want to use, along with the ULMA parameters.

    `./ulma.sh -t TOOLKIT PARAMETERS`

If you want to use a specific toolkit, you can call its endpoint directly as well.

    `./<toolkit>.sh PARAMETERS`

## Parameters

    `INPUT_FILE [OPTIONS] OUTPUT_FILE`

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

