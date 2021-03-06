-module(just_gateway_sup).

-include("gateway.hrl").

-behaviour(supervisor).

-export([start_link/1]).
-export([init/1]).

%% -------------------------------------------------------------------------
%% API
%% -------------------------------------------------------------------------

-spec start_link(#gateway{}) -> {ok, pid()} | {error, any()}.
start_link(Gateway) ->
    supervisor:start_link(?MODULE, [Gateway]).

%% -------------------------------------------------------------------------
%% supervisor callback functions
%% -------------------------------------------------------------------------

init([Gateway]) ->
    {ok, {{one_for_all, 0, 1},
          [{cabinets_sup,
            {just_cabinets_sup, start_link, [Gateway]},
            permanent, infinity, supervisor, [just_cabinets_sup]},
           {amqp_conn_sup, {just_amqp_conn_sup, start_link, [Gateway]},
            permanent, infinity, supervisor, [just_amqp_conn_sup]},
           {response_sink, {just_sink, start_link, [Gateway, response]},
            transient, 5000, worker, [just_sink]},
           {receipt_sink, {just_sink, start_link, [Gateway, receipt]},
            transient, 5000, worker, [just_sink]},
           {message_sink, {just_sink, start_link, [Gateway, message]},
            transient, 5000, worker, [just_sink]},
           {submit_queue, {just_submit_queue, start_link, [Gateway]},
            transient, 5000, worker, [just_submit_queue]},
           {scheduler_sup, {just_scheduler_sup, start_link, [Gateway]},
            permanent, infinity, supervisor, [just_scheduler_sup]},
           {smpp_clients_sup, {just_smpp_clients_sup, start_link, [Gateway]},
            permanent, infinity, supervisor, [just_smpp_clients_sup]},
           {request_acceptor_sup, {just_request_acceptor_sup, start_link, [Gateway]},
            permanent, infinity, supervisor, [just_request_acceptor_sup]},
           {smpp_gateway, {just_gateway, start_link, [Gateway]},
            transient, 5000, worker, [just_gateway]}]}}.
