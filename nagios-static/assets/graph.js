// vim: ft=javascript
// nagios-static/assets/graph.js 
// EugeneKay/scripts
//
// nagiosgraph javascript bits and pieces
//
// $Id$
// License: OSI Artistic License
//          http://www.opensource.org/licenses/artistic-license-2.0.php
// Author:  (c) 2005 Soren Dossing
// Author:  (c) 2008 Alan Brenner, Ithaka Harbors
// Author:  (c) 2010 Matthew Wall

function toggleExpansionState(id, button) {
  var elem = document.getElementById(id);
  toggleDisplay(elem);
  if (elem.style.display == 'inline') {
    button.value = '-';
    button.firstElementChild.style.display = 'none';
    button.lastElementChild.style.display = 'inline';
  } else {
    button.value = '+';
    button.firstElementChild.style.display = 'inline';
    button.lastElementChild.style.display = 'none';
  }
}

function toggleControlsDisplay(button) {
  toggleExpansionState('secondary_controls_box', button);
}

function togglePeriodDisplay(period, button) {
  toggleExpansionState(period, button);
}

function toggleDisplay(elem) {
  if (elem) {
    if (elem.style.display == 'inline') {
      elem.style.display = 'none';
    } else {
      elem.style.display = 'inline';
    }
  }
}
