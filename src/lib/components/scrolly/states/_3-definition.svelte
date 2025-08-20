<script>
  import { onMount, onDestroy } from 'svelte';
	import { fade } from 'svelte/transition';
  
  let termText = $state('');
  let definitionText = $state('');
  let showCursor = $state(true);
  let cursorInterval;
  let isTypingTerm = $state(true);
  
  // Configurable timing
  const TERM_DELAY = 30; // ms per character for term
  const DEFINITION_DELAY = 15; // ms per character for definition
  const PAUSE_BETWEEN = 300; // ms pause between term and definition
  const INITIAL_DELAY = 300; // ms before starting
  
  const fullTerm = 'civic re·spon·si·bil·i·ties:';
  const fullDefinition = 'behaviors people are expected to perform as upstanding members of our national community';
  
  onMount(() => {
    // Typewriter effect for term
    let termIndex = 0;
    const typeTerm = () => {
      if (termIndex < fullTerm.length) {
        termText += fullTerm[termIndex];
        termIndex++;
        setTimeout(typeTerm, TERM_DELAY);
      } else {
        // Move cursor to definition
        isTypingTerm = false;
        // Start definition after term is complete
        setTimeout(typeDefinition, PAUSE_BETWEEN);
      }
    };
    
    // Typewriter effect for definition
    let defIndex = 0;
    const typeDefinition = () => {
      if (defIndex < fullDefinition.length) {
        definitionText += fullDefinition[defIndex];
        defIndex++;
        setTimeout(typeDefinition, DEFINITION_DELAY);
      } else {
        // Stop cursor blinking when complete
        showCursor = false;
        if (cursorInterval) {
          clearInterval(cursorInterval);
        }
      }
    };
    
    // Start typing after initial delay
    setTimeout(typeTerm, INITIAL_DELAY);
    
    // Cursor blink effect
    cursorInterval = setInterval(() => {
      showCursor = !showCursor;
    }, 500);
  });
  
  onDestroy(() => {
    if (cursorInterval) {
      clearInterval(cursorInterval);
    }
  });
</script>

<div class="definition-container" transition:fade|global={{ duration: 400 }}>
  <div class="definition-content">
    <h1 class="term">
      {termText}<span class="cursor" class:visible={showCursor && isTypingTerm}>|</span>
    </h1>
    <p class="definition">
      {definitionText}<span class="cursor" class:visible={showCursor && !isTypingTerm}>|</span>
    </p>
  </div>
</div>

<style lang="scss">
  .definition-container {
    width: 100%;
    height: 100%;
    position: absolute;
    top: 0;
    left: 0;
    z-index: 1;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .definition-content {
    text-align: left;
    max-width: 80%;
    width: 100%;
    font-family: $font-family-body;
    color: #000;
  }

  .term {
    font-weight: bold;
    font-size: 2.5rem;
    margin: 0 0 1rem 0;
    line-height: 1.2;
    color: $color-theme-blue;
    font-family: $font-family-body;
  }

  .definition {
    font-size: 1.8rem;
    margin: 0;
    line-height: 1.4;
    font-weight: normal;
    font-family: $font-family-body;
  }

  .cursor {
    opacity: 0;
    transition: opacity 0.1s ease;
    
    &.visible {
      opacity: 1;
    }
  }
</style>
