<script>
	import { fade } from 'svelte/transition';
	import { goto } from '$app/navigation';
	import Form from './Form.svelte';
	import Submit from './Submit.svelte';
	import Results from './Results.svelte';

	let isLoading = $state(false);
	let results = $state(null);
	let error = $state(null);
	let responses = $state({});
	let submittedUserYesCount = $state(0);

	function handleResults(newResults) {
		if (newResults) {
			results = newResults;
			submittedUserYesCount = newResults.userYesCount || 0;
		}
	}

	function handleLoading(loading) {
		isLoading = loading;
	}

	function handleError(err) {
		error = err;
	}

	$effect(() => {
		return () => {
			document.body.style.overflow = '';
		};
	});
</script>

<div class="quiz-container">
	<div class="quiz-content">
		<div class="quiz-header">
			<h2>What's your civic profile?</h2>
			<p>
				Take the quiz below to find out. For each behavior, indicate whether or not you consider it
				a civic responsibility.
			</p>
			<div class="definition-container">
				<strong>civic responsibilities</strong>
				<span class="definition-text"
					>Behaviors people are expected to perform as upstanding members of our national community.</span
				>
			</div>
		</div>

		<div class="quiz-container">
			{#if isLoading}
				<div class="loading-container">
					<div class="spinner"></div>
					<p>Analyzing your civic profile...</p>
				</div>
			{:else if error}
				<div class="error-container">
					<h3>Something went wrong</h3>
					<p>{error}</p>
					<button class="retry-button" onclick={handleSubmit}>Try Again</button>
				</div>
			{:else}
				{#if results}
					<Results {results} {submittedUserYesCount} />
				{/if}

				{#if !isLoading && !error}
					<Form bind:responses {results} />
				{/if}
			{/if}
		</div>

		{#if !isLoading && !error}
			<Submit
				bind:responses
				{results}
				onResults={handleResults}
				onLoading={handleLoading}
				onError={handleError}
			/>
		{/if}
	</div>
</div>

<style lang="scss">
	@import '../../styles/mixins.scss';

	.quiz-container {
		background-color: var(--bg-color);
		width: 100%;
		min-height: 100vh;
		margin-bottom: 1rem;
		flex: 1;
		padding: 0 1.5rem;

		@include mq('mobile', 'max') {
			padding: 0;
		}
	}

	.quiz-content {
		width: 100%;
		max-width: 700px;
		margin: 0 auto;
		display: flex;
		flex-direction: column;
		padding-bottom: 2rem;
	}

	.quiz-header {
		padding: 2rem;
		display: flex;
		flex-direction: column;
		gap: 2rem;
		margin-top: 120px;

		@include mq('mobile', 'max') {
			padding: 0px 1rem;
			margin-top: 100px;
			gap: 1rem;
		}

		h2 {
			margin: 1rem 0 1rem 0;
			font-size: 3rem;
			font-weight: 700;
			text-align: center;
		}

		p {
			margin: 0 0 1.5rem 0;
			font-size: 1.5rem;
			opacity: 0.95;
			line-height: 1.5;
			text-align: center;

			@include mq('mobile', 'max') {
				font-size: 1.2rem;
			}
		}

		.definition-container {
			display: none;
		}
	}

	.loading-container {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 4rem 2rem;
		text-align: center;

		.spinner {
			width: 50px;
			height: 50px;
			border: 4px solid #f3f3f3;
			border-top: 4px solid var(--color-theme-blue);
			border-radius: 50%;
			animation: spin 1s linear infinite;
			margin-bottom: 2rem;
		}

		p {
			font-size: 1.2rem;
			color: #666;
			margin: 0;
		}
	}

	@keyframes spin {
		0% {
			transform: rotate(0deg);
		}
		100% {
			transform: rotate(360deg);
		}
	}

	.error-container {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 4rem 2rem;
		text-align: center;

		h3 {
			color: var(--color-theme-red);
			margin-bottom: 1rem;
		}

		p {
			color: #666;
			margin-bottom: 2rem;
		}

		.retry-button {
			background-color: var(--color-theme-blue);
			color: white;
			border: none;
			padding: 0.75rem 2rem;
			border-radius: 8px;
			cursor: pointer;
			font-weight: 600;
			transition: all 0.3s ease;

			&:hover {
				background-color: var(--color-theme-blue-light);
			}
		}
	}
</style>
