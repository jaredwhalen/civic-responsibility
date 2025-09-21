<script>
	let { options, activeView, variant = 'default' } = $props();
</script>

{#if options?.series && options.series.length > 1}
	<div class="legend" class:large-font={variant === 'large-font'}>
		<!-- <div class="legend-title">Legend</div> -->
		<div class="legend-items">
			{#each options.series as series}
				{#if series.label != 'Other'}
					<div class="legend-item">
						<div class="legend-dot" style="background-color: {series.color}"></div>
						<span class="legend-label">{series.label}</span>
					</div>
				{:else}
					<div class="legend-item">
						<div class="legend-dots-cluster">
							<div class="legend-dot-small" style="background-color: {series.color}"></div>
							<div class="legend-dot-small" style="background-color: {series.color}"></div>
							<div class="legend-dot-small" style="background-color: {series.color}"></div>
						</div>
						<span class="legend-label">All other groups</span>
					</div>
				{/if}
			{/each}
		</div>
	</div>
{/if}

<style lang="scss">
	.legend {
		// margin-left: 40px;
		// height: 25px;
		.legend-title {
			font-size: 14px;
			font-weight: 800;
			color: #666;
			font-family: sans-serif;
		}

		&.large-font {
			.legend-label {
				font-size: 2rem;
			}

			.legend-dot {
				width: 18px;
				height: 18px;
			}
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

	.legend-dots-cluster {
		display: flex;
		align-items: center;
		gap: 2px;
		position: relative;
	}

	.legend-dot-small {
		width: 8px;
		height: 8px;
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
