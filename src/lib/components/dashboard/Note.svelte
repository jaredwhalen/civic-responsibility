<script>
	let { activeView = 'mean', noteHeight = $bindable(), position = undefined } = $props();
</script>

<div class="n-threshold-note {position}" bind:clientHeight={noteHeight}>
	<h3>Data note</h3>

	<p>
		{#if activeView === 'state' || activeView === 'race'}
			{#if activeView === 'state'}
				Only states with more than N = 40 participants are included;
			{:else}
				Only categories with more than N = 40 participants are included;
			{/if}
		{/if}
		Margin of error = 1% (larger for subgroups)
	</p>
</div>

<style lang="scss">
	// N threshold note
	.n-threshold-note {

		padding-top: 1rem;
		border-top: 1px solid var(--color-gray-200);
		h3 {
			font-size: 1rem;
			font-weight: 600;
			margin: 0px 0px 5px;
		}

		p {
			
			color: #666;
			font-style: italic;
			font-size: 0.8rem;
			
		}

		&.bottom {
			text-align: center;
			padding: 0rem 1rem;
			position: sticky;
			bottom: 0;
			z-index: 1000;
			background-color: var(--bg-color);
			margin-top: 0;
			padding-top: 0;
			border-top: none;
			font-size: 0.75rem;
			line-height: 1;

			h3 {
				display: none;
			}
		}
	}
</style>
