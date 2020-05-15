<script>

	import { onMount } from 'svelte';

	import './lib/codemirror/lua.js';
	import JSONEditor from './lib/jsoneditor.min.js';
	import CodeMirror from './lib/CodeMirror.svelte';

	export let resourceName   = 'luaconsole';
	export let handler        = 'luaconsole';
	export let history        = [];
	export let historyidx     = 0;
	export let output         = '';
	export let onelinecode    = '';
	export let multilinecode  = '';
	export let expressioncode = '';

	let jsonWatcher = null;
	let jsonEditor  = null;
	let outputEl    = null;
	let watchable   = {}

	const updateMultilineCode = (e) => {
		multilinecode = e.detail.value;
	}

	const setHandler = () => {
		
		fetch(`http://${resourceName}/set_handler`, {
			method: 'POST',
			headers: {
				'Accept': 'application/json',
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({name: handler})
		});

	}

	const exec = (code) => {

		fetch(`http://${resourceName}/exec`, {
			method: 'POST',
			headers: {
				'Accept': 'application/json',
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({code, handler})
		});

	}

	const execOneLine = () => {
		history.push(onelinecode);
		exec(onelinecode);
		onelinecode = '';
	}

	const execMultiline = () => {
		exec(multilinecode);
	}

  const onOneLineKeyUp = (e) => {

    switch(e.keyCode) {

      case 13 : {

        execOneLine();

        break;
      }

      case 40 : {

        historyidx--;

        if(historyidx < 0)
          historyidx = history.length;

        if(historyidx < history.length)
          onelinecode = history[historyidx];
        else
          onelinecode = '';

        break;
      }

      case 38 : {

        historyidx++;

        if(historyidx > history.length)
          historyidx = 0;

        if(historyidx < history.length)
          onelinecode = history[historyidx];
        else
          onelinecode = '';

        break;
      }

      default: break;

    }

	};

	const onWatcherKeyUp = async (e) => {

		if(e.keyCode === 13) {

			const rawResponse = await fetch(`http://${resourceName}/watch`, {
				method: 'POST',
				headers: {
					'Accept': 'application/json',
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({name: expressioncode})
			});

			const data = await rawResponse.json();
			watchable  = data.obj;
			
			jsonEditor.set(watchable);

		}

	}

	const onJSONChange = (data) => {

    const diff = [];

    let cancel = false;

    const process = (oldObj, newObj, path = []) => {

      if(typeof oldObj == 'object') {

        if(oldObj instanceof Array) {

          let length = oldObj.length;

          if(newObj.length > length)
            length = newObj.length;

          for(let i=0; i<length; i++)
            process(oldObj[i], newObj[i], path.concat([i]));

        } else {

          const keys    = Object.keys(oldObj || {});
          const newKeys = Object.keys(newObj || {});

          for(let i=0; i<newKeys.length; i++)
            if(keys.indexOf(newKeys[i]) === -1)
              keys.push(newKeys[i]);

          for(let i=0; i<keys.length; i++) {
            const k = keys[i];
            process(oldObj[k], newObj[k], path.concat([k]));
          }

        }

      } else {

        if(oldObj !== newObj) {

          if(oldObj == '__FUNCTION__')
            cancel = true;
          else
            diff.push({path, value: newObj});
        }

      }

    }

    process(watchable, data);

    if(cancel) {

      jsonEditor.set(watchable);
    
    } else {

      watchable = data;

			fetch(`http://${resourceName}/diffwatch`, {
				method: 'POST',
				headers: {
					'Accept': 'application/json',
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({diff})
			});

    }
  }

	window.addEventListener('keydown', (e) => {

		if(e.ctrlKey && e.keyCode === 13) {
			execMultiline();
		}

    if(e.keyCode === 27) {

			fetch(`http://${resourceName}/escape`, {
				method: 'POST',
				headers: {
					'Accept': 'application/json',
					'Content-Type': 'application/json'
				},
				body: '{}'
			});

		}


	});

	window.addEventListener('message', (e) => {

		const msg = e.data;

    switch(msg.action) {

      case 'show' : {
        document.body.style.display = 'block';
        break;
      }

      case 'hide' : {
        document.body.style.display = 'none';
        break;
      }

      case 'print' : {

				output += msg.str + '\n';
				
				outputEl.scrollIntoView({
					behavior: 'instant',
					block   : 'end',
					inline  : 'nearest'
				});

        break;
      }

      case 'clear' : {
        output = '';
        break;
      }

      default: break;

    }

	});

	onMount(() => {

    jsonEditor = new JSONEditor(jsonWatcher, {
      onChangeJSON: data => onJSONChange(data),
    });

	});

</script>

<main>

	<console>
		<left>
			<output><pre bind:this={outputEl}>{output}</pre></output>
			<oneline>
				<input type="text" bind:value={handler}     spellcheck="false" autocorrect="off" on:keyup={setHandler} placeholder="handler">
				<input type="text" bind:value={onelinecode} spellcheck="false" autocorrect="off" on:keyup={onOneLineKeyUp} placeholder="one line code"/>
			</oneline>
			<multiline>
				<CodeMirror on:change={updateMultilineCode} options={{
					theme  : 'monokai',
					tabSize: 2,
					mode   : 'text/x-lua'
				}}/>
			</multiline>
		</left>
		<right>
			<input class="expression" type="text" bind:value={expressioncode} on:keyup={onWatcherKeyUp} spellcheck="false" autocorrect="off" placeholder="expression">
			<div class="json-watcher" bind:this={jsonWatcher}></div>
		</right>
	</console>

</main>

<style>
	
	@import url('https://fonts.googleapis.com/css2?family=Source+Code+Pro&display=swap');

	main {
		position: relative;
		width: 100%;
		height: 100%;;
	}

	input {
		background-color: rgba(255, 255, 255, 0.1);
		border: 0;
		margin: 0;
		padding: 0;
		font-family: 'Source Code Pro';
		color: #EEE;
		height: 32px;
		line-height: 32px;
	}

	input:focus, textarea:focus {
		outline: none;
	}

	console {
		position: relative;
		width: 100%;
		height: 100%;
		display: flex;
		flex-direction: row;
	}

	left {
		width: 80%;
		height: 100%;
		display: flex;
		flex-direction: column;
	}

	right {
		width: 20%;
		height: 100%;
		display: flex;
		flex-direction: column;
		background-color: #FFF;
	}

	right > .expression {
		width: 100%;
		background-color: #111;
	}

	output {
		flex-basis: 50%;
		max-height: 50%;
		background-color: #000;
		font-family: 'Source Code Pro';
		overflow-y: auto;
	}

	output > pre {
		font-family: 'Source Code Pro';
	}

	oneline {
		width: 100%;
		flex-basis: calc(32px + 10px);
		color: #FFF;
	}

	oneline {
		display: flex;
		flex-direction: row;
	}

	oneline > input {
		height: 100%;
		background-color: rgba(255, 255, 255, 0.1);
	}

	oneline > input:nth-child(1) {
		width: 15%;
		background-color: rgba(255, 255, 255, 0.75);
		text-align: center;
		color: #000;
	}

	oneline > input:nth-child(2) {
		width: 85%;
		background-color: rgba(255, 255, 255, 0.1);
	}

	multiline {
		flex-basis: calc(100% - (32px + 10px));
		position: relative;
		color: #FFF;
	}

</style>