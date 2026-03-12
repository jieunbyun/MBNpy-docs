brc
===

Tutorial of using the BRC algorithm can be found `here <https://jieunbyun.github.io/MBNpy-docs/getting_started_BRC.html>`_.

Methods
-------

run
~~~~

.. py:method:: run(probs, sys_fun, rules=None, brs=None, max_sf=np.inf, max_nb=np.inf, max_memory_gb=np.inf, pf_bnd_wr=0.0, max_rules=100, surv_first=True, active_decomp=10, final_decomp=True, display_freq=10)
   :noindex:

    Run the BRC algorithm. There are only two mandatory inputs: component probabilities and system function. 

    :param probs: Dictionary of dictionary of probabilities for each component.
    :type probs: dict of dict
    :param sys_fun: System function.
    :type sys_fun: function
    :param rules: List of rules in case some rules are already known.
    :type rules: list of Rule
    :param brs: List of branches in case branch-and-bound has already been performed.
    :type brs: list of Branch
    :param max_sf: Maximum number of system function runs.
    :type max_sf: int
    :param max_nb: Maximum number of branches.
    :type max_nb: int
    :param max_memory_gb: Maximum residence set memory usage in GB.
    :type max_memory_gb: float
    :param pf_bnd_wr: Bound on the probability ratio of unknown branches to failure branches for early termination.
    :type pf_bnd_wr: float
    :param max_rules: Maximum number of rules to generate.
    :type max_rules: int
    :param surv_first: Whether to prioritise survival branches during decomposition.
    :type surv_first: bool
    :param active_decomp: Decomposition of event space is performed every ``active_decomp`` number of new rules generated.
    :type active_decomp: int
    :param final_decomp: Whether to perform new decomposition when the algorithm terminates.
    :type final_decomp: bool
    :param display_freq: Progress is displayed every ``display_freq`` number of new rules generated.
    :type display_freq: int
    :return: Branches, rules, system results, and monitoring information.
    :rtype: list of Branch, list of dict, pd.DataFrame, dict

eval_rules_prob
~~~~~~~~~~~~~~~

.. py:method:: eval_rules_prob( rules_list, s_or_f, probs )
   :noindex:

    Evaluate the probability of a list of rules given the system state. In case of survival rule, it computes for a rule :math:`\gamma = (\boldsymbol{r}, 1)` :math:`P(\cup_{X \in Scope[\gamma]} X \geq \boldsymbol{r} \langle X \rangle)` and for a failure rule :math:`\gamma = (\boldsymbol{r}, 0)`, it computes :math:`P(\cap_{X \in Scope[\gamma]} X \leq \boldsymbol{r} \langle X \rangle)`.

    :param rules_list: List of rules.
    :type rules_list: list of dict
    :param s_or_f: System state.
    :type s_or_f: str of either 's' or 'f'
    :param probs: Dictionary of dictionary of probabilities for each component.
    :type probs: dict of dict
    :return: Probability of the rules given the system state.
    :rtype: a list of float

