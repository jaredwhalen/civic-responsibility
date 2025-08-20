<script>
	let { options, activeView } = $props();
</script>

<div class="legend">
	{#if options?.series && options.series.length > 1}
		<!-- <div class="legend-title">Legend</div> -->
		<div class="legend-items">
			{#each options.series as series}
				<div class="legend-item">
					<div class="legend-dot" style="background-color: {series.color}"></div>
					<span class="legend-label">{series.label}</span>
				</div>
			{/each}
		</div>
	{/if}
</div>

<style lang="scss">
	.legend {
		margin-left: 40px;
		margin-bottom: 20px;
        height: 25px;
		.legend-title {
			font-size: 14px;
			font-weight: 800;
			color: #666;
			font-family: sans-serif;
		}
	}

	.legend-items {
		display: flex;
		align-items: center;
		gap: 1.5rem;
	}

	.legend-item {
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	.legend-dot {
		width: 12px;
		height: 12px;
		border-radius: 50%;
		flex-shrink: 0;
		border: 1px solid #aaa;
	}

	.legend-label {
		font-size: 14px;
		font-weight: 500;
		color: #666;
		font-family: sans-serif;
	}
</style>
