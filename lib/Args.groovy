/**
 * Handle and construct arguments to be passed to process command line scripts.
 *
 * We see three main areas where arguments can be passed to the command line:
 * 1. there should be reasonable default arguments
 * 2. dynamic arguments should be set depending on the state of the sample, e.g. running certain tools in single- or paired-end mode.
 * 3. users should be able to specify arguments that take precedence over all others if they see fit.
 * 
 * The goal of this class is to provide a convenient way to handle these arguments and construct a consensus set of arguments to pass to a command.
 */
class Args {
    LinkedHashMap<String, String> defaults
    LinkedHashMap<String, String> dynamics
    LinkedHashMap<String, String> users

    /**
     * Construct the Args class using maps from the ext directive namespace for a task.
     */
    Args(Map ext) {
        this.defaults = ext.argsDefault ?: new LinkedHashMap<String, String>()
        this.dynamics = ext.argsDynamic ?: new LinkedHashMap<String, String>()
        this.users    = ext.argsUser    ?: new LinkedHashMap<String, String>()
    }

    /**
     * Build a String of command line arguments by first merging the arguments and then joining them together.
     *
     * @return String consensus command line arguments.
     */
    public String buildArgsString() {
        LinkedHashMap consensusArgs = mergeArgs()

        def builder = new StringBuilder()
        consensusArgs.each { parameter, argument ->
            // separate key:value pairs by spaces
            if (builder.length() > 0) {
                builder.append(' ')
            }
            argument ? builder.append("${parameter} ${argument}") : builder.append("${parameter}")
        }

        return builder.toString()
    }

    /**
     * Merge command line arguments to produce a consensus set of arguments.
     *
     * Arguments in following increasing order of precedence:
     * 1. Default arguments
     * 2. Dynamic arguments
     * 3. User supplied arguments
     *
     * @return LinkedHashMap consensus command line arguments.
     */
    private LinkedHashMap mergeArgs() {
        LinkedHashMap mergedArgs = [:]
        mergedArgs += defaults
        mergedArgs += dynamics
        mergedArgs += users

        return mergedArgs
    }
}