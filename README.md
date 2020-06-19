# Platform Event Publishing Bug

This repository is a bug repro for Salesforce Platform Events when mixing "PublishAfterCommit" and "PublishImmediately" events in Apex.

### Undesirable Behavior

All events that are published should actually fire. However, publishing a "PublishImmediately" event after a "PublishAfterCommit" event swallows the after commit event, and it never ends up firing:

```
EventBus.publish(new MyAfterCommitEvent__e(Label__c='Delay1')); // this event message will never fire
EventBus.publish(new MyImmediateEvent__e(Label__c='Immediate1'));
```

## Reproducing

Defined in this repo are two platform event shapes, one that is "PublishAfterCommit" and one that is "PublishImmediately".

If you want to test it yourself, you can <a href="https://hosted-scratch.herokuapp.com/launch?template=https://github.com/grekker/publish-immediately-bug">click here to have a bug repro scratch org built for you</a>. Fancy.

The scratch org will come with <a href="https://github.com/pozil/streaming-monitor">a great streaming monitor app</a> already installed, so you can immediately start testing. Simply subscribe to both platform events and start running some of these code snippets as anonymous Apex.

## Variations

There are some interesting additional wrinkles and behaviors that shed some light on what might be happening under the hood on this one.

```
EventBus.publish(new MyAfterCommitEvent__e(Label__c='Delay1')); // this event message will never fire
EventBus.publish(new MyImmediateEvent__e(Label__c='Immediate1'));
EventBus.publish(new MyAfterCommitEvent__e(Label__c='Delay2')); // this event message will fire successfully
```

```
EventBus.publish(new MyImmediateEvent__e(Label__c='Immediate1'));
EventBus.publish(new MyAfterCommitEvent__e(Label__c='Delay1')); // this event message will fire successfully
```

Here's where it gets really fun.

```
insert new Account(Name='My Hero');
EventBus.publish(new MyAfterCommitEvent__e(Label__c='Delay1')); // this event message will fire successfully
EventBus.publish(new MyImmediateEvent__e(Label__c='Immediate1'));
```

```
EventBus.publish(new MyAfterCommitEvent__e(Label__c='Delay1')); // this event message will fire successfully
insert new Account(Name='My Hero');
EventBus.publish(new MyImmediateEvent__e(Label__c='Immediate1'));
```

```
EventBus.publish(new MyAfterCommitEvent__e(Label__c='Delay1')); // this event message will never fire
EventBus.publish(new MyImmediateEvent__e(Label__c='Immediate1'));
insert new Account(Name='Too Late');
```

Doing some normal DML, like inserting an SObject, allows the "PublishAfterCommit" event to fire successfully. My guess is the DML forces some kind of queue flush.