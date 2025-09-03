<script>
	import smoothScroll from '$lib/helpers/smoothScroll.js';
	
	let { interactiveMode = $bindable() } = $props();
	
	function handleExploreClick() {
		// Get the transition element and scroll so its bottom is at the bottom of the viewport
		const transitionElement = document.querySelector('.transition');
		if (transitionElement) {
			const elementRect = transitionElement.getBoundingClientRect();
			const elementBottom = elementRect.bottom;
			const viewportHeight = window.innerHeight;
			const scrollOffset = elementBottom - viewportHeight;
			
			// If already at the right position, activate immediately
			if (Math.abs(scrollOffset) < 10) {
				interactiveMode = true;
				return;
			}
			
			// Scroll and activate when complete
			window.scrollBy({
				top: scrollOffset,
				behavior: 'smooth'
			});
			
			// Listen for scroll completion
			let scrollTimeout;
			const checkScrollComplete = () => {
				clearTimeout(scrollTimeout);
				scrollTimeout = setTimeout(() => {
					// Check if scroll has stopped
					const newElementRect = transitionElement.getBoundingClientRect();
					const newScrollOffset = newElementRect.bottom - window.innerHeight;
					
					if (Math.abs(newScrollOffset) < 10) {
						interactiveMode = true;
					} else {
						// Continue checking
						checkScrollComplete();
					}
				}, 100);
			};
			
			checkScrollComplete();
		}
	}
</script>

<div class="transition">
	<div>
		<button data-button="explore" onclick={handleExploreClick}>Click here</button> to explore
		how the data breaks down along demographic lines, gender, location, and more.
	</div>
	<div>
		Or take our <button data-button="quiz">interactive quiz</button> to see how your beliefs compare
		to those of other Americans.
	</div>
</div>

<style lang="scss">
	button {
		color: $color-beacon-dark-green;
		padding: 0.25rem 0.5rem;
		border-radius: 10px;
		border: none;
		cursor: pointer;
		display: inline-block;
		font-size: inherit;

		&[data-button='explore'] {
			background: $color-theme-light;
			color: $color-theme-dark;
		}
		&[data-button='quiz'] {
			background: $color-theme-red;
			color: $color-theme-light;
		}
	}

	.transition {
		display: flex;
		color: $color-theme-light;

		gap: 3rem;
		align-items: center;
		justify-content: center;
		height: 100%;
		width: 100%;

		// background: linear-gradient(
		// 	0deg,
		// 	rgba($color-theme-light, 0) 0%,
		// 	rgba($color-theme-light, 0.75) 20%,
		// 	rgba($color-theme-light, 0.75) 80%,
		// 	rgba($color-theme-light, 0) 100%
		// );
		margin: 0px;
	}
</style>
