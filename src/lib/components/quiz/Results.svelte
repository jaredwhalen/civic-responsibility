<script>
	import duties from '$lib/data/csvs/mean_duties_weighted.csv';
	import { House, Vote, Cake } from '@lucide/svelte';
	import SocialShare from './SocialShare.svelte';

	let { results, submittedUserYesCount } = $props();

	// Sort duties by the number in the name (duties_1, duties_2, etc.)
	const sortedDuties = $derived(
		[...duties].sort((a, b) => {
			const aNum = Number(a.name.replace('duties_', ''));
			const bNum = Number(b.name.replace('duties_', ''));
			return aNum - bNum;
		})
	);

	// Calculate average American yes count
	const averageAmericanYesCount = $derived(
		sortedDuties.filter((duty) => Number(duty.mean) > 50).length
	);

	const iconSize = 30;
</script>

<div class="results-container">
	<h3 class="results-title">Your civic profile</h3>

	<div class="results-table">
		<div class="results-row inline">
			<p>
				You selected <span class="highlight">{submittedUserYesCount}</span>
				responsibilities. The average American selected
				<span class="highlight">{averageAmericanYesCount}</span>
				responsibilities.
			</p>
		</div>

		<div class="results-subhead">
			Based on your {results.totalAnswered === 30
				? 'responses'
				: results.totalAnswered + ' responses'}, you match with...
		</div>

		{#if results.predictions.ideology_tri}
			{@const ideology = results.predictions.ideology_tri}
			{@const ideologyPercent = (ideology.alignment[0] * 100).toFixed(0)}
			<div class="results-row flex">
				<div class="icon-container"><Vote color="#fff" size={iconSize} /></div>
				<div class="content-container">
					<p>
						<span class="highlight black">
							{ideology.predicted[0]} Americans
						</span>

						<span class="highlight blue">{ideologyPercent}%</span> of the time
					</p>
					<div class="progress-bar">
						<div class="progress-fill" style="width: {ideologyPercent}%"></div>
					</div>
				</div>
			</div>
		{/if}

		{#if results.predictions.urban_binary}
			{@const urban = results.predictions.urban_binary}
			{@const urbanPercent = (urban.alignment[0] * 100).toFixed(0)}
			<div class="results-row flex">
				<div class="icon-container"><House color="#fff" size={iconSize} /></div>
				<div class="content-container">
					<p>
						<span class="highlight black">
							{urban.predicted[0]} Americans
						</span>

						<span class="highlight blue">{urbanPercent}%</span> of the time
					</p>
					<div class="progress-bar">
						<div class="progress-fill" style="width: {urbanPercent}%"></div>
					</div>
				</div>
			</div>
		{/if}

		{#if results.predictions.age_binary}
			{@const age = results.predictions.age_binary}
			{@const agePercent = (age.alignment[0] * 100).toFixed(0)}
			<div class="results-row flex">
				<div class="icon-container"><Cake color="#fff" size={iconSize} /></div>
				<div class="content-container">
					<p>
						<span class="highlight black">
							{age.predicted[0] === 'old' ? 'older (50+)' : 'younger (<50)'} Americans
						</span>

						<span class="highlight blue">{agePercent}%</span> of the time
					</p>
					<div class="progress-bar">
						<div class="progress-fill" style="width: {agePercent}%"></div>
					</div>
				</div>
			</div>
		{/if}
	</div>

	<SocialShare {results} />
</div>

<style lang="scss">
	.results-container {
		text-align: center;

		margin: 0 auto;
		background-color: #fff;
		border-radius: 12px;
		box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
		overflow: hidden;
	}

	.results-title {
		font-size: 2.2rem;
		color: #fff;
		margin-bottom: 1.5rem;
		font-weight: 700;
		background-color: var(--color-theme-blue);
		padding: 2rem;
	}

	.results-table {
 
		overflow: hidden; /* Ensures rounded corners apply to inner borders */
		margin-top: 2rem;
	}

	.results-row {
		padding: 1rem 1.5rem;

		text-align: left; /* Left align text */
		color: #333;
		gap: 0.75rem;

		&.flex {
			display: flex;
			align-items: flex-start;
			gap: 1rem;
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
		}
	}

	.results-subhead {
		padding: 0.5rem 1rem;
		// border-bottom: 1px solid #e0e0e0;
		text-align: left;
		color: #000;
		background-color: var(--color-theme-yellow);
		text-align: center;
		display: inline-block;
		border-radius: 20px;
		font-weight: 600;
	}

	.highlight {
		font-weight: bold;

		&.black {
			color: #000;
		}

		&.blue {
			color: var(--color-theme-blue-light);
		}
	}

	.progress-bar {
		width: 100%;
		height: 8px;
		background-color: #f0f0f0;
		border-radius: 4px;
		overflow: hidden;
		margin-top: 0.25rem;
	}

	.progress-fill {
		height: 100%;
		background-color: var(--color-theme-blue-light);
		border-radius: 4px;
		transition: width 0.3s ease;
	}
</style>
