# com.telerik.stripe

Stripe is a payment infrastructure for the internet. Stripe Cordova SDK is built around the well organized REST API. it exposes a global `window.stripe` object that defines various operation to initialze and transfer payments.

Although the object is in the global scope, it is not available until after the `deviceready` event.

    document.addEventListener("deviceready", onDeviceReady, false);
    function onDeviceReady() {
        console.log(window.stripe);
    }


## Installation

You need a Stripe API key for using this plugin, which you can obtain from [Stripe](https://stripe.com/docs). Once you have your API key, you can install the plugin in the following way:

    cordova plugin add url —variable API_KEY="YOUR_API_KEY"

## Methods

- stripe.customers.create
- stripe.customers.list
- stripe.customers.retrieve
- stripe.customers.update
- stripe.customers.remove


- stripe.customers.createCard
- stripe.customers.retrieveCard
- stripe.customers.removeCard


- stripe.charges.create
- stripe.charges.retrieve
- stripe.charges.list
- stripe.charges.update


- stripe.transfers.create
- stripe.transfers.list
- stripe.transfers.retrieve
- stripe.transfers.update
- stripe.transfers.cancel


- stripe.recipients.create
- stripe.recipients.list
- stripe.recipients.retrieve
- stripe.recipients.update
- stripe.recipients.remove

- stripe.subscriptions.create
- stripe.subscriptions.list
- stripe.subscriptions.retrieve
- stripe.subscriptions.update
- stripe.subscriptions.remove

# stripe.customers.create

Creates a new customer object.

## Example

      stripe.customers.create({
          description : "Jon Doe",
          email :  "jon@telerik.com"
      }, function(result){
          // Result contains error or customer object
      });


# stripe.customers.retrieve

Retrieves the details of an existing customer. You need only supply the unique customer identifier that was returned upon customer creation.


## Example

    stripe.customers.retrieve("cus_4sF3AyFe5RqNZk", function(customer){
        // TODO: Your logic
    });


# stripe.customers.list

Returns a list of your customers. The customers are returned sorted by creation date, with the most recently created customers appearing firs

## Example

    stripe.customers.list({
        limit : 1
    }, function(result){
         // asynchronously called
    });


# stripe.customers.remove

Permanently deletes a customer. It cannot be undone. Also immediately cancels any active subscriptions on the customer

## Example

    stripe.customers.remove("cus_4sF3AyFe5RqNZk", function(result){
         // asynchronously called
         if (result.deleted){
           // TODO : Your logic.
         }
    });


# stripe.customers.createCard

Creating a new credit card will not change the card owner's existing default credit card; you should update the customer or recipient with a new default_card for that. If the card's owner has no default credit card, the added credit card will become the default.

## Example

    stripe.customers.createCard("cus_4sF3AyFe5RqNZk",{
        card : {
           number : "4242424242424242",
           exp_month : '08',
           exp_year : '17',
           cvc : '111',
           name : 'Jon Doe'
        }
      },
      function(result){
         // asynchronously called
      });


# stripe.customers.retrieveCard

By default, you can see the 10 most recent cards stored on a customer or recipient directly on the customer or recipient object, but you can also retrieve details about a specific card stored on the customer or recipient.

## Example

    stripe.customers.retrieveCard(
      "cus_4sF3AyFe5RqNZk",
      "card_14iFBp2aMqOhtEaUWEDfI3Dg",
      function(result){
         // asynchronously called
      });


# stripe.customers.removeCard

You can delete cards from a customer or recipient. If you delete a card that is currently the default card on a customer or recipient, the most recently added card will be used as the new default. If you delete the last remaining card on a customer or recipient, the default_card attribute on the card's owner will become null.

Note that for cards belonging to customers, you may want to prevent customers on paid subscriptions from deleting all cards on file so that there is at least one default card for the next invoice payment attempt.


## Example

    stripe.customers.removeCard(
      "cus_4sF3AyFe5RqNZk",
      "card_14iFBp2aMqOhtEaUWEDfI3Dg",
      function(result){
         // asynchronously called
      });


# stripe.charges.create

To charge a credit or a debit card, you create a new charge object. You can retrieve and refund individual charges as well as list all charges. Charges are identified by a unique random ID.

## Example

    stripe.charges.create({
        amount : 400,
        currency : 'usd',
        card : {
          number : "4242424242424242",
          exp_month : '08',
          exp_year : '17',
          cvc : '111',
          name : 'Jon Doe'
        },
        description : "Stripe Test Trasnfer"
      },
      function(result){
         // asynchronously called
      });

# stripe.charges.retrieve

Retrieves the details of a charge that has previously been created. Supply the unique charge ID that was returned from your previous request, and Stripe will return the corresponding charge information. The same information is returned when creating or refunding the charge.

## Example

    stripe.charges.retrieve(
      "ch_14iFBp2aMqOhtEaUftfHNnmN",
      function(result){
         // asynchronously called
      });

# stripe.charges.list

Returns a list of charges you've previously created. The charges are returned in sorted order, with the most recent charges appearing first.

## Example

    stripe.charges.list({
        limit : 3
    },function(result){
        // asynchronously called
    });


# stripe.charges.update

Updates the specified charge by setting the values of the parameters passed. Any parameters not provided will be left unchanged.

This request accepts only the description and metadata as arguments.

## Example

    stripe.charges.update("ch_14iFBp2aMqOhtEaUftfHNnmN", {
        description: "Charge for test@example.com"
    },function(result){
        // asynchronously called
    });


# stripe.transfers.create

When Stripe sends you money or you initiate a transfer to a third party recipient's bank account or debit card, a transfer object will be created. You can retrieve individual transfers as well as list all transfers.

Currently, only US accounts can create transfers.

## Example

    stripe.transfers.create({
      amount: 400,
      currency: "usd",
      recipient: "rp_14gu4C2aMqOhtEaUf64QIvMZ",
      description: "Transfer for test@example.com"
    }, function(transfer) {
      // asynchronously called
    });


# stripe.transfers.list

Returns a list of existing transfers sent to third-party bank accounts or that Stripe has sent you. The transfers are returned in sorted order, with the most recently created transfers appearing first.


## Example

    stripe.transfers.list({
      limit: 3
    }, function(err, transfers) {
      // asynchronously called
    });


# stripe.transfers.retrieve

Retrieves the details of an existing transfer. Supply the unique transfer ID from either a transfer creation request or the transfer list, and Stripe will return the corresponding transfer information.

## Example

    stripe.transfers.retrieve("tr_14iFBq2aMqOhtEaUFN60ASOn", function(transfer) {
      // asynchronously called
    });


# stripe.transfers.update

Updates the specified transfer by setting the values of the parameters passed. Any parameters not provided will be left unchanged.


## Example

    stripe.transfers.update(
      "ch_14iFBp2aMqOhtEaUftfHNnmN",
      {
        description: "Transfer for test@example.com"
      },
      function(transfer) {
        // asynchronously called
      }
    );


# stripe.transfers.cancel

Cancels a transfer that has previously been created. Funds will be refunded to your available balance, and the fees you were originally charged on the transfer will be refunded. You may not cancel transfers that have already been paid out, or automatic Stripe transfers.

## Example

    stripe.transfers.cancel("tr_14iFBq2aMqOhtEaUFN60ASOn", function(transfer) {
      // asynchronously called
    });


# stripe.recipients.create

Creates a new recipient object and verifies both the recipient's identity and, if provided, the recipient's bank account information or debit card.

## Example

    stripe.recipients.create({
      name: "John Doe",
      type: "individual"
    }, function(recipient) {
      // asynchronously called
    });


# stripe.recipients.list

Returns a list of your recipients. The recipients are returned sorted by creation date, with the most recently created recipient appearing first.

## Example

    stripe.recipients.list(function(recipients) {
      // asynchronously called
    });


# stripe.recipients.retrieve

Retrieves the details of an existing recipient. You need only supply the unique recipient identifier that was returned upon recipient creation.


## Example

    stripe.recipients.retrieve("rp_14gu4C2aMqOhtEaUf64QIvMZ", function(recipient) {
      // asynchronously called
    });


# stripe.recipients.update

Updates the specified recipient by setting the values of the parameters passed. Any parameters not provided will be left unchanged.

If you update the name or tax ID, the identity verification will automatically be rerun. If you update the bank account, the bank account validation will automatically be rerun.

## Example

    stripe.recipients.update(
      "rp_14gu4C2aMqOhtEaUf64QIvMZ",
      { description: "Recipient for test@example.com" },
      function(recipient) {
        // asynchronously called
      });

# stripe.recipients.remove

Permanently deletes a recipient. It cannot be undone.

## Example

    stripe.recipients.remove(
      "rp_14gu4C2aMqOhtEaUf64QIvMZ",
      function(result) {
        // asynchronously called
        if (result.deleted){
           // TODO : Your Logic
        }
      }
    );

# stripe.subscriptions.create

Create a subscription for a user.

## Example

    stripe.subscriptions.create(
      "cus_4sF3AyFe5RqNZk",
      "plan_name",
      function(subscription) {
        // asynchronously called
      }
    );

# stripe.subscriptions.list

List all subscriptions for a customer.

## Example

    stripe.subscriptions.list(
      "cus_4sF3AyFe5RqNZk",
      function(subscriptions) {
        // asynchronously called
      }
    );

# stripe.subscriptions.retrieve

Retrieve details for a given subscription id.

## Example

    stripe.subscriptions.retrieve(
      "cus_4sF3AyFe5RqNZk",
      "sub_5THGIl4PrybR1n",
      function(subscription) {
        // asynchronously called
      }
    );

# stripe.subscriptions.update

Update a subscription for a given customer id.

## Example

    stripe.subscriptions.update(
      "cus_4sF3AyFe5RqNZk",
      "sub_5THGIl4PrybR1n",
      {plan: "-JYI_nRwd_ltcGRLnVys"},
      function(subscription) {
        // asynchronously called
      }
    );

# stripe.subscriptions.remove

Remove a subscription for a given customer id.

## Example

    stripe.subscriptions.remove(
      "cus_4sF3AyFe5RqNZk",
      "sub_5THGIl4PrybR1n",
      function(result) {
        // asynchronously called
      }
    );

## Supported Platforms

- iOS
- Android


## Resources

For more information, please refer to the [Stripe Documentation](https://stripe.com/docs/api) for most up-to-date information on API parameters
