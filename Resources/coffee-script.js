// Minimal placeholder CoffeeScript compiler bundle.
// In a production app, replace with the official browser build from coffeescript.org.
(function(global){
  function formatError(message, line){
    var error = new Error(message);
    error.location = { first_line: line || 0 };
    return error;
  }

  var CoffeeScript = {
    compile: function(source, options){
      options = options || {};
      try {
        // Naive transformation: pass through JavaScript-like CoffeeScript.
        // This keeps the preview functional for simple demos.
        return String(source);
      } catch (e) {
        throw formatError(e.message || "Compile failure", e.location && e.location.first_line);
      }
    }
  };

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = CoffeeScript;
  }
  global.CoffeeScript = CoffeeScript;
})(this);
