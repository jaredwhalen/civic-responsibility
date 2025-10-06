<script>
	import { fade } from 'svelte/transition';
	import Form from './Form.svelte';
	import Submit from './Submit.svelte';
	import Results from './Results.svelte';

	let { showQuiz = $bindable() } = $props();
	let isLoading = $state(false);
	let results = $state(null);
	let error = $state(null);
	let responses = $state({});
	let submittedUserYesCount = $state(0);

	function hideQuiz() {
		showQuiz = false;
	}

	function handleResults(newResults) {
		if (newResults) {
			results = newResults;
			// Extract the user's yes count from the results object
			submittedUserYesCount = newResults.userYesCount || 0;
			console.log('Results received:', newResults);
			console.log('Submitted user yes count set to:', submittedUserYesCount);
		}
	}

	function handleLoading(loading) {
		isLoading = loading;
	}

	function handleError(err) {
		error = err;
	}

	// Cleanup on component destroy
	$effect(() => {
		return () => {
			document.body.style.overflow = '';
		};
	});
</script>

<div class="quiz-modal" transition:fade={{ duration: 300 }}>
	<div class="quiz-content">
		<div class="quiz-header">
			<button class="back-button" onclick={hideQuiz} data-button="back">← Back</button>
			<h2>How does your "civic profile" compare with other Americans?</h2>
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
	.quiz-modal {
		position: fixed;
		top: 0;
		left: 0;
		width: 100vw;
		height: 100vh;
		z-index: 10000;
		background-color: var(--bg-color);
		overflow-y: auto;
		border: 10px solid var(--color-theme-blue-light);
	}

	.quiz-content {
		width: 100%;
		max-width: 1000px;
		margin: 0 auto;
		display: flex;
		flex-direction: column;
		min-height: 100vh;
	}

	.quiz-header {
		position: relative;
		padding: 2rem;
		margin-top: 100px;
		display: flex;
		flex-direction: column;
		gap: 2rem;

		.back-button {
			background: none;
			border: none;
			color: #333;
			font-size: 14px;
			font-weight: 800;
			cursor: pointer;
			transition: all 0.2s ease;
			padding: 0.5rem 0;
			z-index: 10;
			text-align: left;

			&:hover {
				color: var(--color-theme-blue);
			}
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
		}

		.definition-container {
			display: flex;
			flex-direction: column;
			justify-content: center;
			border-left: 5px solid var(--color-theme-blue-light);
			padding: 1rem 0px 1rem 1rem;
			background-color: white;
			font-family: 'Georgia', serif;
			font-size: 1.1rem;
			box-shadow: 0 -4px 15px rgba(0, 0, 0, 0.1);
			display: none;
		}
	}

	.quiz-container {
		flex: 1;
		padding: 0px 1.5rem;
	}

	// Loading state
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

	// Error state
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

	// Responsive design
	@media (max-width: 768px) {
		.quiz-content {
			margin: 0;
			max-width: 100%;
		}

		.quiz-header {
			padding: 1.5rem;

			h2 {
				font-size: 1.5rem;
			}

			p {
				font-size: 1rem;
			}
		}

		.quiz-container {
			padding: 1rem;
		}
	}
</style>
