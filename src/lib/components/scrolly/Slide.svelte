<script>
	/**
	 * @typedef {Object} Props
	 * @property {string} [className]
	 * @property {import('svelte').Snippet} [children]
	 */

	/** @type {Props} */
	let { content, className = '', index } = $props();
</script>

<section class={`slide ${className}`} data-index={index}>
	<div class="slide-inner">
		{#each content.text.split('\n') as line}
			<p>{line}</p>
		{/each}
	</div>
</section>

<style lang="scss">
	.slide {
		height: 100vh;
		display: flex;
		align-items: center;
		justify-content: center;
		padding: $spacing-xl 0;
		border-bottom: 1px solid #ccc;

		.slide-inner {
			max-width: 800px;
			background: #fff;
			padding: $spacing-xl;
			border-radius: $border-radius-lg;
			margin: 0 auto;
			width: 100%;
			text-align: center;
		}
	}

	:global {
		[data-index='0'] {
			margin-top: -100vh;
		}
	}
</style>
