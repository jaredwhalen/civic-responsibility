<script>
	import duties from '$lib/data/csvs/mean_duties_weighted.csv';
	import { House, Vote, Cake } from '@lucide/svelte';
	import SocialShare from './SocialShare.svelte';
	import { isMobile } from '$lib/stores/responsive.js';

	let { results, submittedUserYesCount } = $props();

	// Sort duties by the number in the name (duties_1, duties_2, etc.)
	const sortedDuties = $derived(
		[...duties].sort((a, b) => {
			const aNum = Number(a.name.replace('duties_', ''));
			const bNum = Number(b.name.replace('duties_', ''));
			return aNum - bNum;
		})
	);



	// Calculate civic profile based on submittedUserYesCount
	const civicProfile = $derived.by(() => {
		if (submittedUserYesCount <= 16) return 'Civic Minimalist';
		if (submittedUserYesCount <= 20) return 'Civic Pragmatist';
		if (submittedUserYesCount <= 25) return 'Civic Believer';
		return 'Civic Champion';
	});

	const iconSize = $isMobile ? 24 : 30;
</script>

<div class="results-container">
	<div class="results-title">
		<div class="profile-label">Your civic profile</div>
		<div class="profile-name">{civicProfile}</div>
	</div>

	<div class="results-table">
		<div class="results-row summary">
			<p>
				You selected <span class="highlight">{submittedUserYesCount}</span>
				responsibilities. The average American selected
				<span class="highlight">20</span>
				responsibilities.
			</p>
		</div>

		<div class="results-subhead">
			Based on your responses, you align most closely with...
		</div>

	{#if results.summary}
		{@const ideology = results.summary.find(item => item.group_var === 'ideology_tri')}
		{#if ideology}
			{@const ideologyPercent = ideology.percent_fit.toFixed(0)}
			<div class="results-row flex">
				<div class="icon-container"><Vote color="#fff" size={iconSize} /></div>
				<div class="content-container">
					<p>
						<span class="highlight black">
							{ideology.predicted_group} Americans
						</span>

						<span class="highlight blue">({ideologyPercent}% match)</span>
					</p>
					<div class="progress-bar">
						<div class="progress-fill" style="width: {ideologyPercent}%"></div>
					</div>
				</div>
			</div>
		{/if}
	{/if}

	{#if results.summary}
		{@const urban = results.summary.find(item => item.group_var === 'urban_binary')}
		{#if urban}
			{@const urbanPercent = urban.percent_fit.toFixed(0)}
			<div class="results-row flex">
				<div class="icon-container"><House color="#fff" size={iconSize} /></div>
				<div class="content-container">
					<p>
						<span class="highlight black">
							{urban.predicted_group} Americans
						</span>

						<span class="highlight blue">({urbanPercent}% match)</span>
					</p>
					<div class="progress-bar">
						<div class="progress-fill" style="width: {urbanPercent}%"></div>
					</div>
				</div>
			</div>
		{/if}
	{/if}

	{#if results.summary}
		{@const age = results.summary.find(item => item.group_var === 'age_binary')}
		{#if age}
			{@const agePercent = age.percent_fit.toFixed(0)}
			<div class="results-row flex">
				<div class="icon-container"><Cake color="#fff" size={iconSize} /></div>
				<div class="content-container">
					<p>
						<span class="highlight black">
							{age.predicted_group === 'old' ? 'older (50+)' : 'younger (<50)'} Americans
						</span>

						<span class="highlight blue">({agePercent}% match)</span>
					</p>
					<div class="progress-bar">
						<div class="progress-fill" style="width: {agePercent}%"></div>
					</div>
				</div>
			</div>
		{/if}
	{/if}
	</div>

	<SocialShare {results} />
</div>

<style lang="scss">
	@import '../../styles/mixins.scss';
	
	.results-container {
		text-align: center;
		margin: 0 auto;
		background-color: #fff;
		border-radius: 12px;
		box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
		overflow: hidden;



		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			border-radius: 8px;
			box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
			margin: 0px 0.5rem;
		}
	}

	.results-title {
		background-color: var(--color-theme-blue);
		padding: 2rem;
		text-align: center;

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			padding: 1.5rem 1rem;
		}

		.profile-label {
			font-size: 1.4rem;
			color: #fff;
			font-weight: 400;
			margin-bottom: 0.5rem;
			opacity: 0.9;

			// Mobile responsive adjustments
			@include mq('mobile', 'max') {
				font-size: 1.1rem;
			}
		}

		.profile-name {
			font-size: 2.8rem;
			color: #fff;
			font-weight: 700;
			text-transform: uppercase;
			letter-spacing: 0.05em;

			// Mobile responsive adjustments
			@include mq('mobile', 'max') {
				font-size: 2rem;
				line-height: 1.1;
				letter-spacing: 0.03em;
			}
		}
	}

	.results-table {
 
		overflow: hidden; /* Ensures rounded corners apply to inner borders */

	}

	.results-row {
		padding: 1rem 1.5rem;
		text-align: left; /* Left align text */
		color: #333;
		gap: 0.75rem;

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			padding: 0.8rem 1rem;
		}

		&.summary {
			text-align: center;
			margin: 1.5rem 0;

			// Mobile responsive adjustments
			@include mq('mobile', 'max') {
				margin: 1rem 0;
			}
		}

		&.flex {
			display: flex;
			align-items: flex-start;
			gap: 1rem;

			// Mobile responsive adjustments
			@include mq('mobile', 'max') {
				gap: 0.75rem;
			}
		}

		.content-container {
			flex: 1;
			display: flex;
			flex-direction: column;
			gap: 0.5rem;

			p {
				display: flex;
				align-items: center;
				gap: 0.5rem;
				margin: 0;

				// Mobile responsive adjustments
				@include mq('mobile', 'max') {
					flex-direction: column;
					align-items: flex-start;
					gap: 0.25rem;
				}
			}
		}

		span {
			text-transform: capitalize;
		}

		&:last-child {
			border-bottom: none; /* No border on the last row */
		}

		p {
			margin: 0; /* Remove default paragraph margin */
			font-size: 1.4rem;

			// Mobile responsive adjustments
			@include mq('mobile', 'max') {
				font-size: 1.1rem;
			}
		}

		.icon-container {
			width: 50px;
			height: 50px;
			display: flex;
			align-items: center;
			justify-content: center;
			background-color: var(--color-theme-blue);
			border-radius: 50%;
			padding: 0.5rem;

			// Mobile responsive adjustments
			@include mq('mobile', 'max') {
				width: 40px;
				height: 40px;
				padding: 0.4rem;
			}
		}
	}

	.results-subhead {
		padding: 0.5rem 1rem;
		margin-bottom: 0.5rem;
		text-align: left;
		color: #000;
		background-color: var(--color-theme-yellow);
		text-align: center;
		display: inline-block;
		border-radius: 20px;
		font-weight: 600;

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			padding: 0.4rem 0.8rem;
			margin: 0.5rem 1rem 1rem 1rem;
			font-size: 0.9rem;
			border-radius: 16px;
		}

		.percentage-match {
			display: block;
			font-size: 0.9em;
			margin-top: 0.25rem;
			opacity: 0.8;
		}
	}

	.highlight {
		font-weight: bold;

		&.black {
			color: #000;
		}

		&.blue {
			color: var(--color-theme-blue-light);
			text-transform: none;
			font-weight: 500;
		}
	}

	.progress-bar {
		width: 100%;
		height: 8px;
		background-color: #f0f0f0;
		border-radius: 4px;
		overflow: hidden;
		margin-top: 0.25rem;

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			height: 6px;
			border-radius: 3px;
			margin-top: 0.5rem;
		}
	}

	.progress-fill {
		height: 100%;
		background-color: var(--color-theme-blue-light);
		border-radius: 4px;
		transition: width 0.3s ease;

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			border-radius: 3px;
		}
	}
</style>
