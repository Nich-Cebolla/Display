/**
 * @classdesc - `dDefaultOptions` is a container for options objects for functions which use
 * an `Options` parameter, instead of a series of individual parameters. `dDefaultOptions`' properties
 * are set at the top of each code file that has one or more functions that uses an options object.
 *
 * All functions which use an options object allow you to define your own default options object that
 * supercede the built-in defaults. When I write functions with many options, I write them this way
 * because I find that when I use the functions, I tend to use the same options frequently, and so
 * being able to define a separate set of defaults is convenient. You can still pass an options object
 * to the function parameter to adjust any options on top of your defaults.
 *
 * To use this feature, you just need to define a class object somewhere in the code with a name
 * using this format: d<function name>Config. Here's some examples:
 * @example
 *  class dWrapTextConfig {
 *      static AdjustObject := true
 *      , BreakChars := '-/'
 *  }
 * @
 */
class dDefaultOptions {
    /**
     * @description - Sets the base object such that the values are used in this priority order:
     * - 1: The input object.
     * - 2: The configuration object (if present).
     * - 3: The built-in default object.
     * @param {Object} Options - The input object.
     * @param {Object} Default - The default options object.
     * @param {Class} [Config] - The user default object, if one exists.
     * @return {Object} - The input object after setting the base.
     */
    static Call(Options, Default, Config?) {
        if IsSet(Config) {
            ObjSetBase(Config, Default)
            ObjSetBase(Options, Config)
        } else {
            ObjSetBase(Options, Default)
        }
        return Options
    }
}
