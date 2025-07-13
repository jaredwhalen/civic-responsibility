<script>
	/**
	 * @typedef {Object} Props
	 * @property {number} currentSlide
	 * @property {number} scrollProgress
	 * @property {string} scrollDirection
	 */

	/** @type {Props} */
	let { currentSlide, scrollProgress, scrollDirection } = $props();
</script>

<div class="debug-panel">
	<h3>Scroll Debug</h3>
	<div class="debug-item">
		<strong>Current Slide:</strong> {currentSlide}
	</div>
	<div class="debug-item">
		<strong>Scroll Progress:</strong> {(scrollProgress * 100).toFixed(1)}%
	</div>
	<div class="debug-item">
		<strong>Direction:</strong> {scrollDirection}
	</div>
	<div class="progress-bar">
		<div class="progress-fill" style="width: {scrollProgress * 100}%"></div>
	</div>
</div>

<style lang="scss">
	.debug-panel {
		position: fixed;
		top: 100px;
		left: $spacing-lg;
		background: rgba(0, 0, 0, 0.8);
		color: white;
		padding: $spacing-md;
		border-radius: $border-radius-md;
		font-family: monospace;
		font-size: $font-size-sm;
		z-index: 3000;
		min-width: 200px;
		
		h3 {
			margin: 0 0 $spacing-sm 0;
			font-size: $font-size-base;
			color: #b6e36c;
		}
		
		.debug-item {
			margin-bottom: $spacing-xs;
			
			strong {
				color: #b6e36c;
			}
		}
		
		.progress-bar {
			width: 100%;
			height: 4px;
			background: rgba(255, 255, 255, 0.2);
			border-radius: 2px;
			margin-top: $spacing-sm;
			overflow: hidden;
			
			.progress-fill {
				height: 100%;
				background: #b6e36c;
				transition: width 0.1s ease;
			}
		}
	}
</style> 