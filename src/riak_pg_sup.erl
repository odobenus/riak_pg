%% @author Christopher Meiklejohn <christopher.meiklejohn@gmail.com>
%% @copyright 2013 Christopher Meiklejohn.
%% @doc Application supervisor.

-module(riak_pg_sup).
-author('Christopher Meiklejohn <christopher.meiklejohn@gmail.com>').

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init(_Args) ->
    VMaster = {riak_pg_vnode_master,
               {riak_core_vnode_master, start_link, [riak_pg_vnode]},
                permanent, 5000, worker, [riak_core_vnode_master]},

    MessageProxy = {riak_pg_message_proxy_vnode_master,
                    {riak_core_vnode_master, start_link, [riak_pg_message_proxy_vnode]},
                     permanent, 5000, worker, [riak_core_vnode_master]},

    Publications = {riak_pg_publications_vnode_master,
                    {riak_core_vnode_master, start_link, [riak_pg_publications_vnode]},
                     permanent, 5000, worker, [riak_core_vnode_master]},

    Subscriptions = {riak_pg_subscriptions_vnode_master,
                     {riak_core_vnode_master, start_link, [riak_pg_subscriptions_vnode]},
                      permanent, 5000, worker, [riak_core_vnode_master]},

    PublishFSM = {riak_pg_publish_fsm_sup,
                  {riak_pg_publish_fsm_sup, start_link, []},
                   permanent, infinity, supervisor, [riak_pg_publish_fsm_sup]},

    SubscribeFSM = {riak_pg_subscribe_fsm_sup,
                    {riak_pg_subscribe_fsm_sup, start_link, []},
                     permanent, infinity, supervisor, [riak_pg_subscribe_fsm_sup]},

    UnsubscribeFSM = {riak_pg_unsubscribe_fsm_sup,
                    {riak_pg_unsubscribe_fsm_sup, start_link, []},
                     permanent, infinity, supervisor, [riak_pg_unsubscribe_fsm_sup]},

    {ok, {{one_for_one, 5, 10}, [VMaster,
                                 MessageProxy,
                                 Publications,
                                 Subscriptions,
                                 PublishFSM,
                                 SubscribeFSM,
                                 UnsubscribeFSM]}}.