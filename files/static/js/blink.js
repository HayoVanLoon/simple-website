'use strict';

(function () {
  function blink(elem, alt, interval) {
    if (interval === -1) {
      interval = 500 + Math.random() * 50;
    }
    let alts = [];
    for (let i = 0; i < elem.classList.length; i += 1) {
      let cls = elem.classList[i]
      if (cls.startsWith("blink-") && !cls.startsWith("blink-1")) {
        alts.push(cls.substring(6));
      }
    }
    if (alts.length === 0) {
      alts.push(alt);
    }
    console.log(alts);
    let f = function () {
      if (elem.classList.contains("blink-1")) {
        let i = Math.floor(Math.random() * alts.length);
        elem.style.color = alts[i];
        elem.classList.remove("blink-1")
      } else {
        elem.style.color = "";
        elem.classList.add("blink-1")
      }
      window.setTimeout(f, interval);
    };
    return f;
  }

  let elems = document.getElementsByClassName("blink");
  for (let i = 0; i < elems.length; i += 1) {
    blink(elems[i], "blue", -1)();
  }
})();
